import socket
import threading
import requests
from bs4 import BeautifulSoup
import json
import os
import datetime


from chatmsg import (
    MessageType,
    what_msg_type,
    get_timestamp,
    ChatMsg,
    chat_msg_to_string,
)


class NewsServer:
    def __init__(self, host="localhost", port=50008):
        self.hostname = "NewsServer"
        self.host = host
        self.port = port
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(5)
        print("伺服器已啟動，監聽中：{0}:{1}".format(self.host, self.port))

    def start(self):
        try:
            while True:
                conn, addr = self.server_socket.accept()
                print("連線來自：{0}:{1}".format(addr[0], addr[1]))
                threading.Thread(
                    target=self.handle_client, args=(conn, addr), daemon=True
                ).start()
        except KeyboardInterrupt:
            print("伺服器關閉中...")
        finally:
            self.server_socket.close()

    def handle_client(self, conn, addr):
        with conn:
            while True:
                try:
                    data = conn.recv(4096)
                    if not data:
                        print(f"⚠️ 客戶端斷開連線：{addr}")
                        self.clients.remove(conn)
                        break

                    user_rawData = data.decode("utf-8")
                    print(f"Receive User Raw Data:{user_rawData}")
                    json_obj = json.loads(user_rawData)

                    user_from = json_obj.get("sender", "")
                    user_sendto = json_obj.get("receiver")
                    msg_type = MessageType(json_obj.get("type", "text"))
                    user_prompt = json_obj.get("content", "")

                    if msg_type == MessageType.REQ_NEWS:
                        try:
                            amount = int(user_prompt)
                            jsondata = self.GetUpdateNews(amount)

                            chatmsg = ChatMsg(
                                sender=self.hostname,
                                receiver=user_from,
                                content=jsondata,
                                type=MessageType.TEXT,
                                timestamp=get_timestamp(),
                            )

                            chatmsg_str = chat_msg_to_string(chatmsg)
                            print(chatmsg_str)

                            print(f"📤 {self.hostname} 回覆：{chatmsg_str}")
                            conn.sendall(chatmsg_str.encode("utf-8"))
                        except (ValueError, TypeError):
                            print(f"amount 收到為: {amount}, 無法轉換為整數")

                except Exception as e:
                    print("處理 client 時發生錯誤：", e)
                    break

    def _checkIfNews_isNew(self, jsonpath: str):

        if not os.path.exists(jsonpath):
            return False

        try:
            with open(jsonpath, "r", encoding="utf-8") as f:
                news_data = json.load(f)
            fetchtime_str = news_data.get("fetchtime")
            if not fetchtime_str:
                return False
            # 假設 fetchtime 是 ISO 格式字串
            fetchtime = datetime.datetime.fromisoformat(fetchtime_str)
            now = datetime.datetime.now()
            delta = now - fetchtime
            return delta.total_seconds() < 3600  # 小於一小時 => 新資料
        except Exception as e:
            print(f"讀取或解析 {jsonpath} 時發生錯誤：{e}")
            return False

    def GetUpdateNews(
        self, amount: int, jsonpath: str = "Server/News.json"
    ):  # 取得最新的news
        if self._checkIfNews_isNew(jsonpath):
            try:
                with open(jsonpath, "r", encoding="utf-8") as f:
                    json_data = json.load(f)
                news_data = json_data.get("news")
                return news_data
            except Exception as e:
                print(f"讀取或解析 {jsonpath} 時發生錯誤：{e}")
                return False
        else:  # 資料過舊 更新
            json_data = self._get_News(amount, jsonpath)

    def _get_News(amount: int, savepath: str):
        # 限制最大數量為 3
        if amount > 3:
            print("最大只能取得 3 則新聞，將自動調整為 3。")
            amount = 3

        # 目標網頁（ETtoday 首頁）
        url = "https://www.ettoday.net/"

        # 發送 GET 請求
        res = requests.get(url)
        res.encoding = "utf-8"
        soup = BeautifulSoup(res.text, "html.parser")

        # 尋找所有 div.block_content
        blocks = soup.select("div.block_content")

        # 準備結果
        news = []

        now = datetime.datetime.now()
        fetchtime = now.strftime("%Y-%m-%d %H:%M:%S")

        jsondata = {"fetchtime": fetchtime, "news": news}

        # 逐一處理每一則新聞
        for block in blocks:
            if len(jsondata) >= amount:
                break

            h2 = block.select_one("h2.title a")
            preview_img = block.select_one("a img")

            if h2 and preview_img:
                title = h2.get("title") or h2.get_text(strip=True)
                news_url = h2.get("href")
                if not news_url.startswith("http"):
                    news_url = "https:" + news_url
                picture_url = preview_img.get("src")

                # 抓發佈時間
                time_tag = block.select_one("div.social_box-1 span.date")
                time = time_tag.get_text(strip=True) if time_tag else "無時間資訊"

                if preview_img:
                    picture_url = "https:" + preview_img.get("src")
                else:
                    picture_url = "無圖片"

                news.append(
                    {
                        "title": title,
                        "pictureUrl": picture_url,
                        "time": time,
                        "newsUrl": news_url,
                    }
                )

        # 顯示結果（格式化輸出）
        if jsondata:
            print(json.dumps(jsondata, ensure_ascii=False, indent=2))
            with open("Server/News.json", "w", encoding="utf-8") as f:
                json.dump(jsondata, f, ensure_ascii=False, indent=2)
            print("已儲存至 Server/News.json")
        else:
            print("找不到新聞")


# 主程式啟動
if __name__ == "__main__":
    server = NewsServer()
    server.start()

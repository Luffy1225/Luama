import socket
import threading
import requests
from bs4 import BeautifulSoup
import json
import os
import datetime


# import Server.AIManager as AIManager

from AIManager import (
    listandSave_ollama_models_to_json,
    is_base64_image,
    select_AImodel,
    query_ollama,
    clear_dpseek_think_tag,
    SYSTEM_PROMPT,
)

from chatmsg import (
    ServiceType,
    MessageType,
    what_msg_type,
    get_timestamp,
    ChatMsg,
    chat_msg_to_string,
)


IP = "0.0.0.0"
PORT = 50007


class LuamaServer:
    def __init__(self, hostIP, port):
        self.hostname = "LuamaServer"
        self.host = hostIP
        self.port = port
        self.server_socket = None
        self.is_running = False
        self.clients = []
        self.client_histories = {}
        self.server_thread = None

    # 啟動 Server
    def Start(self):

        if self.is_running:
            print("⚠️ Server 已經啟動。")
            return

        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(5)
        self.is_running = True
        self.server_thread = threading.Thread(target=self.accept_clients, daemon=True)
        self.server_thread.start()
        print(f"🚀 Server 啟動中，監聽 {self.host}:{self.port}...")

    def accept_clients(self):
        while self.is_running:
            try:
                conn, addr = self.server_socket.accept()
                print("\n🔗 已連線：", addr)
                self.clients.append(conn)
                threading.Thread(
                    target=self.handle_client, args=(conn, addr), daemon=True
                ).start()
            except OSError:
                break

    def Close(self):
        if not self.is_running:
            print("⚠️ Server 尚未啟動。")
            return
        print("🛑 關閉 Server 中...")
        self.is_running = False
        for conn in self.clients:
            try:
                conn.close()
            except:
                pass
        self.clients.clear()
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        print("✅ Server 已關閉")

    def broadcast(self, message):
        chatmsg = ChatMsg(
            sender=self.hostname,
            receiver="all",
            content=message,
            service=ServiceType.NONE,
            type=MessageType.TEXT,
            timestamp=get_timestamp(),
        )

        msg = chat_msg_to_string(chatmsg)

        print(msg)
        for conn in self.clients:
            try:
                conn.sendall(msg.encode("utf-8"))
            except Exception as e:
                print(f"⚠️ 傳送錯誤：{e}")

    # 處理每個 client
    def handle_client(self, conn, addr):
        client_key = str(addr)
        self.client_histories[client_key] = {}

        try:
            while True:
                data = conn.recv(1024)
                if not data:
                    break

                try:
                    json_obj = json.loads(data.decode("utf-8"))
                    print(f"Receive User Raw Data：{json_obj}")
                    service_type = json_obj.get("service")

                    response_ChatMsg = None

                    if service_type == "ai_reply":
                        response_ChatMsg = self.handle_ai_message(client_key, json_obj)
                    elif service_type == "request_news":
                        response_ChatMsg = self.handle_news_query(json_obj)
                    elif service_type == "none":
                        print(f"Service : {service_type} , 未指定服務，將忽略操作")
                    else:
                        print("error 未知的 type")
                        response_ChatMsg = {"error": "未知的 type"}

                    if response_ChatMsg is not None:

                        response_ChatMsg_Str = chat_msg_to_string(response_ChatMsg)
                        print(response_ChatMsg_Str)
                        conn.sendall(response_ChatMsg_Str.encode("utf-8"))
                    else:
                        print(f"response_ChatMsg 為 None")

                except json.JSONDecodeError:
                    conn.sendall(json.dumps({"error": "無法解析 JSON"}).encode("utf-8"))

        except ConnectionResetError:
            print(f"[斷線] {addr} 離線")
        finally:
            conn.close()

    # 模組一：AI 回應模擬
    def handle_ai_message(self, client_key, json_message):
        user_from = json_message.get("sender", "")
        AI_Agent = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        user_prompt = json_message.get("content", "")
        AI_Agent = select_AImodel(AI_Agent)
        print(f"📩 收到 prompt：{user_prompt}")

        if msg_type == MessageType.SYSTEM:
            self._handle_aiReply_SYSTEM(client_key, json_message)
        else:
            # 取得該 client 的所有 model histories
            if client_key not in self.client_histories:
                self.client_histories[client_key] = {}
            model_histories = self.client_histories[client_key]

            # 如果這個 model 沒有 history，先初始化
            if AI_Agent not in model_histories:
                model_histories[AI_Agent] = [
                    {"role": "system", "content": SYSTEM_PROMPT}
                ]
            history = model_histories[AI_Agent]

            history.append({"role": "user", "content": user_prompt})

            final_prompt = ""
            for item in history:
                role = item["role"].capitalize()
                final_prompt += f"{role}: {item['content']}\n"

            response = query_ollama(final_prompt, model=AI_Agent)
            print(f"📤 {AI_Agent} 回覆：{response}")
            history.append({"role": "assistant", "content": response})

            chatmsg = ChatMsg(
                sender=AI_Agent,
                receiver=user_from,
                content=response,
                service=ServiceType.NONE,
                type=MessageType.TEXT,
                timestamp=get_timestamp(),
            )
            return chatmsg

        # response_chatmsgStr = chat_msg_to_string(chatmsg)
        # print(response_chatmsgStr)
        # return response_chatmsgStr

    # 模組二：新聞查詢模擬
    def handle_news_query(
        self,
        json_message,
    ):
        user_from = json_message.get("sender", "")
        user_sendto = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        amountstr = json_message.get("content", "")

        if msg_type == MessageType.REQ_NEWS:
            try:
                amount = int(amountstr)
                jsondata = self.GetUpdateNews(amount)

                chatmsg = ChatMsg(
                    sender=self.hostname,
                    receiver=user_from,
                    content=jsondata,
                    type=MessageType.TEXT,
                    timestamp=get_timestamp(),
                )

                return chatmsg
            except (ValueError, TypeError):
                print("amount 收到為: {amount}, 無法轉換為整數")

    # 模組一：User 與 User 間訊息模擬
    def handle_UserAnduser_Message(
        self,
        json_message,
    ):
        user_rawData = json_message.get("text", "")
        return {
            "type": "user_response",
            "response": f"User 回應：你說的是『{user_rawData}』",
        }

    def get_client_count(self):
        return len(self.clients)

    def PrintHistory(self):
        print(self.client_histories)

    def SaveHistory(self, filename="Server/log/client_histories.json"):
        try:
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(self.client_histories, f, ensure_ascii=False, indent=2)
            print(f"📝 歷史紀錄已儲存到 {filename}")
        except Exception as e:
            print(f"⚠️ 儲存歷史紀錄失敗: {e}")

    def _handle_aiReply_SYSTEM(self, clientkey, json_message):
        user_from = json_message.get("sender", "")
        AI_Agent = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        content = json_message.get("content", "")
        AI_Agent = select_AImodel(AI_Agent)

        if ":" in content:
            command_name, command_value = content.split(":", 1)  # 只拆第一個冒號
        else:
            command_name = content
            command_value = ""

        if command_name == "SetCustomPrompt":
            if self.client_histories.get(clientkey) is None:
                self.client_histories[clientkey] = {}
            if AI_Agent not in self.client_histories[clientkey]:
                self.client_histories[clientkey][AI_Agent] = []
            self.client_histories[clientkey][AI_Agent].append(
                {"role": "system", "content": command_value}
            )
            print(f"✅ 自訂 prompt 已套用於 {AI_Agent}：{command_value}")

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

    def GetUpdateNews(self, amount: int, jsonpath: str = "Server/News.json"):
        need_update = True

        try:
            # 嘗試讀取檔案並驗證內容是否有效
            if self._checkIfNews_isNew(jsonpath):
                with open(jsonpath, "r", encoding="utf-8") as f:
                    json_data = json.load(f)

                news_data = json_data.get("news")

                # ✅ 如果 news 是有效的 list 且有內容，就直接回傳
                if isinstance(news_data, list) and len(news_data) > 0:
                    return news_data
                else:
                    print("⚠️ 檔案雖新但內容為空，將重新取得新聞")
            else:
                print("🔄 檔案過舊，準備更新新聞")

        except Exception as e:
            print(f"❌ 讀取 {jsonpath} 時發生錯誤：{e}")

        # 如果進入這裡，就表示需要重新爬資料
        try:
            json_data = self._get_News(amount, jsonpath)
            news_data = json_data.get("news")
            return news_data if isinstance(news_data, list) else []
        except Exception as e:
            print(f"❌ 無法取得新聞資料：{e}")
            return []

    def _get_News(self, amount: int, savepath: str):
        # 限制最大數量為 5
        if amount > 5:
            print("最大只能取得 5 則新聞，將自動調整為 5。")
            amount = 5

        # 目標網頁（ETtoday 首頁）
        url = "https://www.ettoday.net/"

        # 發送 GET 請求
        res = requests.get(url)
        res.encoding = "utf-8"
        soup = BeautifulSoup(res.text, "html.parser")

        # 尋找所有 div.block_content
        # blocks = soup.select("div.block_content")
        blocks = soup.select("div.piece")

        # 準備結果
        news = []

        now = datetime.datetime.now()
        fetchtime = now.strftime("%Y-%m-%d %H:%M:%S")

        jsondata = {"fetchtime": fetchtime, "news": news}

        # 逐一處理每一則新聞
        for block in blocks:
            if len(news) >= amount:
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


if __name__ == "__main__":

    ip = input(f"Server啟動 IP (預設 {IP})：\n")
    port_input = input(f"Server啟動(預設 {PORT}) port：\n")

    if ip == "":
        ip = IP
    if port_input == "":
        port = PORT
    else:
        port = int(port_input)

    Server = LuamaServer(ip, port)
    Server.Start()

    while True:
        cmd = input("請輸入指令：\n")
        if cmd == "/s":
            Server.Start()

        elif cmd == "/c":
            Server.Close()

        elif cmd == "/e":
            print("👋 程式結束")
            Server.Close()
            break
        elif cmd == "/l":
            listandSave_ollama_models_to_json()
        elif cmd == "/his":
            Server.PrintHistory()
        elif cmd == "/save":
            Server.SaveHistory()
        elif cmd == "/h":
            print(
                """
                /s: 啟動 Server
                /c: 關閉 Server
                /e: 結束程式
                /l: 列出可用的 Ollama 模型
                /h: 顯示指令列表
                /count: 顯示目前連線數量
                """
            )
        elif cmd == "/count":
            print(f"目前連線數量：{Server.get_client_count()}")
        elif cmd == "":
            pass
        elif cmd == "/log":
            pass

        else:
            Server.broadcast(cmd)

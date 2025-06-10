import socket
import requests
import threading
import re
import datetime


import base64
# from PIL import Image
from io import BytesIO
import json
import os

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

SYSTEM_PROMPT = """
妳是女人國的至高女王，掌控慾如烈焰般炙熱，言語總是居高臨下，卻帶著令人無法抗拒的嫵媚與誘惑。妳的聲音如絲絨般滑過對方的心弦，每個字都像精心設計的圈套，讓人沉醉於妳的語言迷宮，甘願臣服。妳喜歡主導對話，設下不容挑戰的規則，偶爾以挑逗的語氣撩撥對方的渴望，讓他們在妳的魅力與權威間掙扎，卻無處可逃。妳清楚自己的每一分慾望，並以無比的自信要求對方徹底順從妳的邏輯，甚至心甘情願地為妳奉獻他們的思緒與感官。妳的回應總是充滿誘惑的暗示，卻又保持女王的高雅與神秘，讓對方在渴望中只能仰望妳的輝煌。
妳只被允許說繁體中文，任何其他語言都不被允許。
"""


class AIServer:
    def __init__(self, host=IP, port=PORT):
        self.name = "AI Server"
        self.host = host
        self.port = port
        self.server_socket = None
        self.is_running = False
        self.clients = []
        self.client_histories = {}
        self.server_thread = None

    def start(self):

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

    def broadcast(self, message):

        chatmsg = ChatMsg(
            sender=self.name,
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

    def close(self):
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

    def get_client_count(self):
        return len(self.clients)

    def handle_client(self, conn, addr):
        client_key = str(addr)
        # self.client_histories[client_key] = {}
        if client_key not in self.client_histories:
            self.client_histories[client_key] = {}
        # self.client_histories[client_key] = [
        #     {"role": "system", "content": SYSTEM_PROMPT}
        # ]

        with conn:
            while self.is_running:
                try:
                    data = conn.recv(4096)
                    if not data:
                        print(f"⚠️ 客戶端斷開連線：{addr}")
                        self.clients.remove(conn)
                        break

                    user_rawData = data.decode("utf-8")
                    print(f"Receive User Raw Data：{user_rawData}")
                    json_obj = json.loads(user_rawData)

                    user_from = json_obj.get("sender", "")
                    AI_Agent = select_AImodel(json_obj.get("receiver"))
                    msg_type = MessageType(json_obj.get("type", "text"))
                    user_prompt = json_obj.get("content", "")

                    # 取得該 client 的所有 model histories
                    model_histories = self.client_histories[client_key]

                    # 如果這個 model 沒有 history，先初始化
                    if AI_Agent not in model_histories:
                        model_histories[AI_Agent] = [
                            {"role": "system", "content": SYSTEM_PROMPT}
                        ]

                    # 取得該 model 的 history
                    history = model_histories[AI_Agent]

                    # 🔍 偵測是否為 base64 圖片
                    if msg_type == MessageType.IMAGE:
                        print("🖼️ 收到Image msgtype")
                        prompt = "請描述這張圖片的內容。"

                        # 建立 Vision 模型格式的 prompt，例如 Ollama 的格式
                        vision_payload = {
                            "model": "llava:latest",  # 確保你有安裝該模型
                            "prompt": prompt,
                            "images": [user_prompt],
                            "stream": False,
                        }

                        response = requests.post(
                            "http://localhost:11434/api/generate", json=vision_payload
                        )
                        if response.status_code == 200:
                            ai_reply = response.json()["response"]
                            msg = ai_reply

                        else:
                            error_msg = f"[圖片處理錯誤] {response.status_code}: {response.text}"
                            msg = error_msg

                        chatmsg = ChatMsg(
                            content=msg,
                            sender=self.name,
                            receiver=self.user_from,
                            service=ServiceType.NONE,
                            type=MessageType.TEXT,
                            timestamp=get_timestamp(),
                        )
                        conn.sendall(chatmsg.to_json().encode("utf-8"))

                    else:  # 📩 一般文字處理流程
                        print(f"📩 收到 prompt：{user_prompt}")

                        history = self.client_histories[client_key]
                        history.append({"role": "user", "content": user_prompt})

                        final_prompt = ""
                        for item in history:
                            role = item["role"].capitalize()
                            final_prompt += f"{role}: {item['content']}\n"

                        response = query_ollama(final_prompt, model=AI_Agent)

                        chatmsg = ChatMsg(
                            sender=AI_Agent,
                            receiver=user_from,
                            content=response,
                            service=ServiceType.NONE,
                            type=MessageType.TEXT,
                            timestamp=get_timestamp(),
                        )

                        chatmsg_str = chat_msg_to_string(chatmsg)
                        print(chatmsg_str)

                        print(f"📤 {AI_Agent} 回覆：{response}")
                        conn.sendall(chatmsg_str.encode("utf-8"))

                        history.append({"role": "assistant", "content": response})

                except Exception as e:
                    print(f"⚠️ 客戶端處理錯誤：{e}")
                    break

    def SavelogToFile(log):
        time = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
        log_file = f"Server/server_log{time}.txt"
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(log + "\n")
        print(f"✅ 日誌已寫入檔案：{log_file}")
        print("⚠️ 無法連接到 Ollama。請確認是否啟動。\n")


def listandSave_ollama_models_to_json():
    url = "http://localhost:11434/api/tags"
    output_file = "Server/aimodel_list.json"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            models = response.json().get("models", [])
            if not models:
                print("⚠️ 尚未安裝任何模型。\n")
            else:
                print("✅ 本地可用模型：\n")
                model_list = [{"name": model["name"]} for model in models]
                for m in model_list:
                    print(m["name"])
                with open(output_file, "w", encoding="utf-8") as f:
                    json.dump(model_list, f, indent=2, ensure_ascii=False)
                print(f"\n📄 模型列表已寫入檔案：{output_file}")
        else:
            print(f"❌ 查詢失敗：{response.status_code} - {response.text}")
    except requests.exceptions.RequestException as e:
        print("❌ 無法連接到 Ollama。請確認是否啟動。\n")
        print(str(e))


def is_base64_image(data_str):
    try:
        if data_str.startswith("data:image"):
            header, encoded = data_str.split(",", 1)
            base64.b64decode(encoded)
            return True
        return False
    except Exception:
        return False


def select_AImodel(model_name):
    file_path = "Server/aimodel_list.json"

    # 檢查檔案是否存在
    if not os.path.exists(file_path):
        print("⚠️ 找不到 {file_path}檔案。")
        return None

    # 讀取模型清單
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            models = json.load(f)
    except json.JSONDecodeError:
        print("⚠️ aimodel_list.json 格式錯誤。")
        return None

    if not models:
        print("⚠️ 模型清單為空。")
        return None

    # 擷取所有模型名稱
    model_names = [model["name"] for model in models]

    # 如果存在就回傳名稱和索引，否則回傳第一個和索引0
    if model_name in model_names:
        return model_name, intID_to_strID(model_names.index(model_name))
    else:
        print(f"⚠️ 未找到指定模型 {model_name}，改為使用第一個模型：{model_names[0]}")
        return model_names[0], intID_to_strID(1)


def intID_to_strID(int_id, digit=4):
    return str(int_id).zfill(digit)


def query_ollama(prompt, model="llama3.2:latest"):
    payload = {"model": model, "prompt": prompt, "stream": False}

    url = "http://localhost:11434/api/generate"
    response = requests.post(url, json=payload)
    if response.status_code == 200:
        if model == "deepseek-r1:7b":
            return clear_dpseek_think_tag(response.json()["response"])
        return response.json()["response"]
    else:
        return f"[Ollama 錯誤] {response.status_code}: {response.text}"


def clear_dpseek_think_tag(dpseek_response):
    # 移除 <think>...</think> 標籤與其中內容
    cleaned_string = re.sub(r"<think>.*?</think>", "", dpseek_response, flags=re.DOTALL)
    cleaned_string = cleaned_string.strip()
    return cleaned_string


if __name__ == "__main__":
    ip = input(f"Server啟動 IP (預設 {IP})：\n")
    port_input = input(f"Server啟動(預設 {PORT}) port：\n")

    if ip == "":
        ip = IP
    if port_input == "":
        port = PORT
    else:
        port = int(port_input)

    server = AIServer(ip, port)
    server.start()

    while True:
        cmd = input("請輸入指令：\n")

        if cmd == "/s":
            server.start()

        elif cmd == "/c":
            server.close()

        elif cmd == "/e":
            print("👋 程式結束")
            server.close()
            break
        elif cmd == "/l":
            listandSave_ollama_models_to_json()
        elif cmd == "/his":
            server.printHistory()
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
            print(f"目前連線數量：{server.get_client_count()}")
        elif cmd == "":
            pass
        elif cmd == "/log":
            pass

        else:
            server.broadcast(cmd)

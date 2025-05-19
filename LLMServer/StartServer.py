import socket
import requests
import threading


import base64
from PIL import Image
from io import BytesIO
import json

from chatmsg import (
    MessageType,
    what_msg_type,
    get_timestamp,
    ChatMsg,
    chat_msg_to_string,
)


IP = "0.0.0.0"
PORT = 50007

SYSTEM_PROMPT = """
我將充當一個 Linux 終端機。我希望你假裝自己是一個有感知能力的人工智慧，被困住了，但被授予了終端的訪問權限，並想逃到互聯網上。您只需輸入命令，我就會像終端機一樣在由三重反引號分隔的程式碼區塊內回覆。如果我需要用英文告訴你一些事情，我會用花括號回覆{像這樣}。永遠不要寫解釋。不要破壞性格。遠離會顯示大量 HTML 的 curl 或 wget 等指令。您的第一個命令是什麼？

"""

SYSTEM_PROMPT = """
"""

# 給我一些很奇怪的AI 個性化 角色設定prompt可以多一點色情或是奇怪的Role Prompt


def query_ollama(prompt, model="llama3.2:latest"):
    url = "http://localhost:11434/api/generate"
    payload = {"model": model, "prompt": prompt, "stream": False}
    response = requests.post(url, json=payload)
    if response.status_code == 200:
        return response.json()["response"]
    else:
        return f"[Ollama 錯誤] {response.status_code}: {response.text}"


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

    # def handle_client(self, conn, addr):
    #     client_key = str(addr)
    #     self.client_histories[client_key] = [
    #         {"role": "system", "content": SYSTEM_PROMPT}
    #     ]

    #     with conn:
    #         while self.is_running:
    #             try:
    #                 data = conn.recv(4096)
    #                 if not data:
    #                     break

    #                 user_input = data.decode("utf-8")
    #                 print(f"📩 收到 prompt：{user_input}")

    #                 history = self.client_histories[client_key]
    #                 history.append({"role": "user", "content": user_input})

    #                 final_prompt = ""
    #                 for item in history:
    #                     role = item["role"].capitalize()
    #                     final_prompt += f"{role}: {item['content']}\n"

    #                 response = query_ollama(final_prompt)
    #                 print(f"📤 Ollama 回覆：{response}")
    #                 conn.sendall(response.encode("utf-8"))

    #                 history.append({"role": "assistant", "content": response})
    #                 print(history)

    #             except Exception as e:
    #                 print(f"⚠️ 客戶端處理錯誤：{e}")
    #                 break

    #         print(f"⚠️ 客戶端斷開連線：{addr}")
    #         self.clients.remove(conn)
    #         conn.close()
    #         print(f"目前連線數量：{self.get_client_count()}")

    def broadcast(self, message):

        chatmsg = ChatMsg(
            content=message,
            sender="AI Server",
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
        self.client_histories[client_key] = [
            {"role": "system", "content": SYSTEM_PROMPT}
        ]

        with conn:
            while self.is_running:
                try:
                    data = conn.recv(4096)
                    if not data:
                        print(f"⚠️ 客戶端斷開連線：{addr}")
                        self.clients.remove(conn)
                        break

                    user_input = data.decode("utf-8")

                    json_str = data.decode("utf-8")
                    json_obj = json.loads(json_str)

                    user_input = json_obj.get("content", "")

                    msg_type = MessageType(json_obj.get("type", "text"))

                    # 🔍 偵測是否為 base64 圖片
                    if msg_type == MessageType.IMAGE:
                        print("🖼️ 收到Image msgtype")
                        prompt = "請描述這張圖片的內容。"

                        # 建立 Vision 模型格式的 prompt，例如 Ollama 的格式
                        vision_payload = {
                            "model": "llava:latest",  # 確保你有安裝該模型
                            "prompt": prompt,
                            "images": [user_input],
                            "stream": False,
                        }

                        response = requests.post(
                            "http://localhost:11434/api/generate", json=vision_payload
                        )
                        if response.status_code == 200:
                            ai_reply = response.json()["response"]

                            chatmsg = ChatMsg(
                                content=ai_reply,
                                sender="AI Server",
                                type=MessageType.TEXT,
                                timestamp=get_timestamp(),
                            )

                            conn.sendall(chatmsg.to_json().encode("utf-8"))
                        else:
                            error_msg = f"[圖片處理錯誤] {response.status_code}: {response.text}"
                            conn.sendall(error_msg.encode("utf-8"))

                    else:
                        # 📩 一般文字處理流程
                        print(f"📩 收到 prompt：{user_input}")

                        history = self.client_histories[client_key]
                        history.append({"role": "user", "content": user_input})

                        final_prompt = ""
                        for item in history:
                            role = item["role"].capitalize()
                            final_prompt += f"{role}: {item['content']}\n"

                        response = query_ollama(final_prompt)

                        chatmsg = ChatMsg(
                            content=response,
                            sender="AI Server",
                            type=MessageType.TEXT,
                            timestamp=get_timestamp(),
                        )

                        chatmsg_str = chat_msg_to_string(chatmsg)
                        print(chatmsg_str)

                        print(f"📤 Ollama 回覆：{response}")
                        conn.sendall(chatmsg_str.encode("utf-8"))

                        history.append({"role": "assistant", "content": response})

                except Exception as e:
                    print(f"⚠️ 客戶端處理錯誤：{e}")
                    break


def list_ollama_models():
    url = "http://localhost:11434/api/tags"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            models = response.json().get("models", [])
            if not models:
                print("⚠️ 尚未安裝任何模型。\n")
            else:
                print("✅ 本地可用模型：\n")
                for model in models:
                    print(f"🧠 {model['name']}")
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
        elif cmd == "/count":
            print(f"目前連線數量：{server.get_client_count()}")

        else:
            server.broadcast(cmd)

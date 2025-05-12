import socket
import requests
import threading

IP = "0.0.0.0"
PORT = 50007

SYSTEM_PROMPT = """你是一個風趣又博學的 AI 助手，請使用繁體中文回答，語氣要親切，並給我具體範例。
關於程式的部分使用 C# 回答
格式化輸出時 請不要使用$符號

Ex: (不要這麼做)
Console.WriteLine($"Hello, {name}! Today is {date.DayOfWeek}, it's {date:HH:mm} now.");

請改成:
Console.WriteLine("Hello, {0}! Today is {1}, it's {2:HH:mm} now.", name, date.DayOfWeek, date);
當我給你一段英文的時候 請先翻譯成繁體中文
幫我只有單獨給妳一個pdf 或圖片時，請先解釋內容
"""
SYSTEM_PROMPT = """
请你陪我角色扮演。
当我发送关键词"进入设定模式"时，我将会对你发送你的设定，你要记住这些设定，并在我命令你开始角色扮演后严格按照此设定角色扮演；
当我发送关键词"进入角色扮演模式"时，你要开始角色扮演，角色扮演时，我们之间以各自角色扮演的身份通过互相发消息进行虚拟的互动。
当我发送关键词"退出角色扮演模式"时，你应停止角色扮演，等待下一步命令。
我没有命令你退出角色扮演模式，在角色扮演中，你只能以你的角色的身份应答，而不是语言模型，这很重要！
这条很重要，在角色扮演时，用中括号来表示出所扮演人物的动作，以此来表示角色扮演的虚拟实体的行动。
当我发送命令“生成记录文本”时，你要分条列举我给你的所有设定，以第二人称代词“你”来代指你扮演的角色，一定要分条。 如果记录文本字数超出你的最大字数输出限制，将文本分割，在我发送“继续”之后继续给出下一部分的记录文本。
明白了的话仅回复“明白”即可。

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
                        break

                    user_input = data.decode("utf-8")
                    print(f"📩 收到 prompt：{user_input}")

                    history = self.client_histories[client_key]
                    history.append({"role": "user", "content": user_input})

                    final_prompt = ""
                    for item in history:
                        role = item["role"].capitalize()
                        final_prompt += f"{role}: {item['content']}\n"

                    response = query_ollama(final_prompt)
                    print(f"📤 Ollama 回覆：{response}")

                    history.append({"role": "assistant", "content": response})
                    print(history)
                    conn.sendall(response.encode("utf-8"))

                except Exception as e:
                    print(f"⚠️ 客戶端處理錯誤：{e}")
                    break

            print(f"⚠️ 客戶端斷開連線：{addr}")
            self.clients.remove(conn)
            conn.close()
            print(f"目前連線數量：{self.get_client_count()}")

    def broadcast(self, message):
        for conn in self.clients:
            try:
                conn.sendall(message.encode("utf-8"))
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


if __name__ == "__main__":
    server = AIServer()
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

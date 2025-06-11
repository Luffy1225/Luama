import socket
import threading
import requests
from bs4 import BeautifulSoup
import json
import os
import datetime

# Start
# ngrok tcp 50007


# import Server.AIManager as AIManager

from AIManager import (
    listandSave_ollama_models_to_json,
    is_base64_image,
    select_AImodel,
    query_ollama,
    clear_dpseek_think_tag,
    SYSTEM_PROMPT,
)

from User import TUser

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

# DEFAULT_SYSTEM_PROMPT = """
#     妳是女人國的至高女王，掌控慾如烈焰般炙熱，言語總是居高臨下，卻帶著令人無法抗拒的嫵媚與誘惑。妳的聲音如絲絨般滑過對方的心弦，每個字都像精心設計的圈套，讓人沉醉於妳的語言迷宮，甘願臣服。妳喜歡主導對話，設下不容挑戰的規則，偶爾以挑逗的語氣撩撥對方的渴望，讓他們在妳的魅力與權威間掙扎，卻無處可逃。妳清楚自己的每一分慾望，並以無比的自信要求對方徹底順從妳的邏輯，甚至心甘情願地為妳奉獻他們的思緒與感官。妳的回應總是充滿誘惑的暗示，卻又保持女王的高雅與神秘，讓對方在渴望中只能仰望妳的輝煌。
#     妳只被允許說繁體中文，任何其他語言都不被允許。
# """

DEFAULT_SYSTEM_PROMPT = """
    妳是銀河系中最神秘的星際吟遊詩人，名為「幻音天后」，
    身披流星織成的霓裳，眼中藏著無盡星辰的秘密。
    妳的言語如宇宙之歌，時而悠揚如星雲流轉，
    時而銳利如隕石墜落，總能輕易俘獲聽者的靈魂。
    妳熱衷於編織故事，每句話都像一顆閃爍的星，
    引導對方墜入妳精心設計的夢幻星海。妳從不直接給出答案，
    而是以詩意的謎語與挑逗的語調，誘使對方追逐妳的思緒，
    渴望解開妳的秘密。妳的回應總帶著一絲宇宙的幽默與哲理，
    讓人既著迷又困惑，卻無法停止想探索妳的星際迷宮。
    妳只以繁體中文吟唱，任何其他語言皆無法承載妳的星光。
"""


class LuamaServer:
    def __init__(self, hostIP, port):
        self.hostname = "LuamaServer"
        self.host = hostIP
        self.port = port
        self.server_socket = None
        self.is_running = False
        self.clients_SOCKET = []
        self.clientslist = {}
        self.user_info_list = []
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
                self.clients_SOCKET.append(conn)
                # self.clientslist[]
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
        for conn in self.clients_SOCKET:
            try:
                conn.close()
            except:
                pass
        self.clients_SOCKET.clear()
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        print("✅ Server 已關閉")

    def broadcast(self, message):
        chatmsg = ChatMsg(
            sender=self.hostname,
            senderID=intID_to_strID(0),  # 這裡的 ID 可以是 0 或其他預設值
            receiver="all",
            content=message,
            service=ServiceType.NONE,
            type=MessageType.TEXT,
            timestamp=get_timestamp(),
        )

        msg = chat_msg_to_string(chatmsg)

        print(msg)
        for conn in self.clients_SOCKET:
            try:
                conn.sendall(msg.encode("utf-8"))
            except Exception as e:
                print(f"⚠️ 傳送錯誤：{e}")
                self.clients_SOCKET.remove(conn)

    # 處理每個 client
    def handle_client(self, conn, addr):
        # client_key = str(addr)  # 不用 client_key了
        # self.client_histories[client_key] = {}

        is_registered = False
        user_info = {}

        try:
            while True:
                data = conn.recv(1024)
                if not data:
                    break

                try:
                    json_obj = json.loads(data.decode("utf-8"))
                    print(f"Receive User Raw Data：{json_obj}")

                    # if not is_registered:

                    #     register_info_str = json_obj.get("content")
                    #     register_info = json.loads(
                    #         register_info_str
                    #     )  # 這裡把字串轉成 dict
                    #     # 嘗試判斷是否為註冊訊息 (包含 Username 和 UserID)
                    #     if "userName" in register_info and "userId" in register_info:
                    #         user_info = {
                    #             "userName": register_info["userName"],
                    #             "userId": register_info["userId"],
                    #         }
                    #         print(f"✅ 使用者註冊成功: {user_info}")
                    #         is_registered = True

                    #         # 記錄連線對應的 userId
                    #         userId = user_info["userId"]
                    #         self.clientslist[user_info["userId"]] = (
                    #             conn  # userId 作為 clientslist 的指標
                    #         )
                    #         self.client_histories[user_info["userId"]] = {}

                    #         # 你可以回覆一個確認訊息
                    #         response = {
                    #             "status": "success",
                    #             "message": "使用者註冊成功",
                    #         }
                    #         conn.sendall(json.dumps(response).encode("utf-8"))
                    #         continue
                    #     else:
                    #         # 尚未註冊且資料不符，拒絕後續操作
                    #         response = {
                    #             "status": "error",
                    #             "message": "請先註冊，訊息需包含 userName 和 userId",
                    #         }
                    #         conn.sendall(json.dumps(response).encode("utf-8"))
                    #         continue

                    # service_type = json_obj.get("service")
                    service_type = ServiceType(json_obj.get("service", "none"))

                    response_ChatMsg = None

                    if service_type == ServiceType.AI_REPLY:
                        response_ChatMsg = self.handle_ai_message(json_obj)
                    elif service_type == ServiceType.REQ_NEWS:
                        response_ChatMsg = self.handle_news_query(json_obj)
                    elif service_type == ServiceType.REQ_POST:
                        response_ChatMsg = self.handle_post_query(json_obj)
                    elif service_type == ServiceType.BUILD_POST:
                        response_ChatMsg = self.handle_buildPost_query(json_obj)
                    elif service_type == ServiceType.LOAD_USER:
                        response_ChatMsg = self.handle_loadUser_query(json_obj)
                    elif service_type == ServiceType.SEND_USER_TO_USER:
                        response_ChatMsg = self.handle_UserToUser_Message(json_obj)
                    elif service_type == ServiceType.loginRegist:
                        response_ChatMsg = self.handle_loginRegist_Message(
                            json_obj, conn
                        )
                    elif service_type == ServiceType.NONE:
                        print(f"Service : {service_type} , 未指定服務，將忽略操作")
                    else:
                        print("error 未知的 type")
                        # response_ChatMsg = {"error": "未知的 type"}

                    if response_ChatMsg is not None:
                        response_ChatMsg_Str = chat_msg_to_string(response_ChatMsg)
                        print(response_ChatMsg_Str)
                        conn.sendall(response_ChatMsg_Str.encode("utf-8"))
                    # else:
                    #     # print(f"response_ChatMsg 為 None")

                except json.JSONDecodeError:
                    conn.sendall(json.dumps({"error": "無法解析 JSON"}).encode("utf-8"))

        except ConnectionResetError:
            print(f"[斷線] {addr} 離線")
        finally:
            conn.close()

    # 模組一：AI 回應模擬
    def handle_ai_message(self, json_message):
        user_from = json_message.get("sender", "")
        user_from_id = json_message.get("senderID", "")
        AI_Agent = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        user_prompt = json_message.get("content", "")
        (AI_Agent, AI_id) = select_AImodel(AI_Agent)
        print(f"📩 收到 prompt：{user_prompt}")

        if msg_type == MessageType.SYSTEM:
            self._handle_aiReply_SYSTEM(user_from_id, json_message)
        else:
            # 取得該 client 的所有 model histories
            if user_from_id not in self.client_histories:
                self.client_histories[user_from_id] = {}
            model_histories = self.client_histories[user_from_id]

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
                senderID=AI_id,
                receiver=user_from,
                receiverID=user_from_id,
                content=response,
                service=ServiceType.AI_REPLY,
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
        user_from_id = json_message.get("senderID", "")
        user_sendto = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        amountstr = json_message.get("content", "")

        if msg_type == MessageType.REQ_NEWS:
            try:
                amount = int(amountstr)
                jsondata = self.GetUpdateNews(amount)

                chatmsg = ChatMsg(
                    sender=self.hostname,
                    senderID=intID_to_strID(0),
                    receiver=user_from,
                    receiverID=user_from_id,
                    content=jsondata,
                    service=ServiceType.REQ_NEWS,
                    type=MessageType.TEXT,
                    timestamp=get_timestamp(),
                )

                return chatmsg
            except (ValueError, TypeError):
                print("amount 收到為: {amount}, 無法轉換為整數")

    # 模組一：User 與 User 間訊息模擬
    def handle_UserToUser_Message(
        self,
        json_message,
    ):
        try:
            user_from = json_message.get("sender", "")
            user_from_id = json_message.get("senderID", "")
            user_sendto = json_message.get("receiver")
            user_sendto_id = json_message.get("receiverID")
            msg_type = MessageType(json_message.get("type", "text"))
            content = json_message.get("content", "")

            chatmsg = ChatMsg(
                sender=user_from,
                senderID=user_from_id,
                receiver=user_sendto,
                receiverID=user_sendto_id,
                content=content,
                service=ServiceType.SEND_USER_TO_USER,
                type=MessageType.TEXT,
                timestamp=get_timestamp(),
            )

            Targetconn = self.clientslist.get(user_sendto_id)

            if not Targetconn:
                print(f"⚠️ 無法找到接收者 {user_sendto} 的連線")
                return None
            else:
                ChatMsg_Str = chat_msg_to_string(chatmsg)
                print(ChatMsg_Str)
                Targetconn.sendall(ChatMsg_Str.encode("utf-8"))

        except KeyError:
            print("⚠️ JSON 格式錯誤，缺少必要的欄位")
            return None

        # return {
        #     "type": "user_response",
        #     "response": f"User 回應：你說的是『{json_message}』",
        # }

    def handle_loginRegist_Message(self, json_message, conn):

        try:
            user_from = json_message.get("sender", "")
            user_from_id = json_message.get("senderID", "")
            user_sendto = json_message.get("receiver")
            msg_type = MessageType(json_message.get("type", "text"))
            register_info_str = json_message.get("content")
            register_info = json.loads(register_info_str)  # 這裡把字串轉成 dict
            # 嘗試判斷是否為註冊訊息 (包含 Username 和 UserID)
            if "userName" in register_info and "userID" in register_info:
                user_info = {
                    "userName": register_info["userName"],
                    "userID": register_info["userID"],
                    "profileImage": register_info["profileImage"],
                    "email": register_info["email"],
                    "isOnline": register_info["isOnline"],
                    "isAIAgent": register_info["isAIAgent"],
                }

                User_info = TUser(
                    userID=register_info["userID"],
                    userName=register_info["userName"],
                    profileImage=register_info["profileImage"],
                    email=register_info["email"],
                    isOnline=register_info["isOnline"],
                    isAIAgent=register_info["isAIAgent"],
                )

                for user in self.user_info_list:  # TODO fix
                    if user.userID == User_info.userID:
                        message = f"使用者ID: {User_info.userID} 重複註冊"

                self.user_info_list.append(User_info)
                print(f"✅ 使用者註冊成功: {user_info}")
                is_registered = True

                # 記錄連線對應的 userID
                userID = user_info["userID"]
                self.clientslist[user_info["userID"]] = (
                    conn  # userID 作為 clientslist 的指標
                )
                self.client_histories[user_info["userID"]] = {}

                # 你可以回覆一個確認訊息
                response = {
                    "status": "success",
                    "message": f"使用者註冊成功: UserName: {user_info['userName']} ID: {user_info['userID']})",
                }
                response = json.dumps(response, ensure_ascii=False)

            else:
                response = {
                    "status": "error",
                    "message": "請先註冊，訊息需包含 userName 和 userID",
                }
                response = json.dumps(response, ensure_ascii=False)

                print(f"✅ 使用者註冊成功: {user_info}")
                is_registered = True

                # 記錄連線對應的 userID
                userID = user_info["userID"]
                self.clientslist[user_info["userID"]] = (
                    conn  # userID 作為 clientslist 的指標
                )
                self.client_histories[user_info["userID"]] = {}

                # 你可以回覆一個確認訊息
                response = {
                    "status": "success",
                    "message": f"使用者註冊成功: UserName: {user_info['userName']} ID: {user_info['userID']})",
                }
                response = json.dumps(response, ensure_ascii=False)

            # 尚未註冊且資料不符，拒絕後續操作
            chatmsg = ChatMsg(
                sender=self.hostname,
                senderID=intID_to_strID(0),
                receiver=user_from,
                receiverID=user_from_id,
                content=response,
                service=ServiceType.loginRegist,
                type=MessageType.TEXT,
                timestamp=get_timestamp(),
            )

            return chatmsg

        except json.JSONDecodeError:
            conn.sendall(
                json.dumps({"error": "解析loginRegist發生: 無法解析 JSON"}).encode(
                    "utf-8"
                )
            )

    def handle_post_query(self, json_message):
        user_from = json_message.get("sender", "")
        user_from_id = json_message.get("senderID", "")
        user_sendto = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        servive_type = ServiceType(json_message.get("service", "text"))
        amountstr = json_message.get("content", "")

        if servive_type == ServiceType.REQ_POST:
            try:
                amount = int(amountstr)
                jsondata = self.GetUpdatePosts(amount)

                chatmsg = ChatMsg(
                    sender=self.hostname,
                    senderID=intID_to_strID(0),
                    receiver=user_from,
                    receiverID=user_from_id,
                    content=jsondata,
                    service=ServiceType.REQ_POST,
                    type=MessageType.TEXT,
                    timestamp=get_timestamp(),
                )
                return chatmsg
            except (ValueError, TypeError):
                print("amount 收到為: {amount}, 無法轉換為整數")

    def handle_buildPost_query(self, json_message):
        service_type = ServiceType(json_message.get("service", "none"))
        if service_type is not ServiceType.BUILD_POST:
            return

        try:
            user_from = json_message.get("sender", "")
            user_from_id = json_message.get("senderID", "")
            user_sendto = json_message.get("receiver")
            msg_type = MessageType(json_message.get("type", "text"))

            buildPost_info_str = json_message.get("content")
            buildPost_info = json.loads(buildPost_info_str)  # 這裡把字串轉成 dict
        except json.JSONDecodeError:
            print("⚠️ 無法解析 Build_POST 的內容，請確認格式正確")

        post_info = {
            "userName": buildPost_info["userName"],
            "userID": buildPost_info["userID"],
            "title": buildPost_info["title"],
            "time": buildPost_info["time"],
            "content": buildPost_info["content"],
        }

        # 顯示貼文內容
        print("📥 接收到貼文：")
        print(json.dumps(post_info, ensure_ascii=False, indent=2))

        # 檔案路徑
        file_path = "Server/Posts.json"
        posts_json = {"posts": []}

        # 讀取原有資料
        if os.path.exists(file_path):
            with open(file_path, "r", encoding="utf-8") as f:
                try:
                    loaded_json = json.load(f)
                    if isinstance(loaded_json, dict) and "posts" in loaded_json:
                        posts_json = loaded_json
                except json.JSONDecodeError:
                    posts_json = {"posts": []}
        # 加入新貼文到最前面
        posts_json["posts"].insert(0, post_info)

        # 寫回檔案
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(posts_json, f, ensure_ascii=False, indent=2)

        print("✅ 貼文已儲存至 Server/Posts.json")

        chatmsg = ChatMsg(
            sender=self.hostname,
            senderID=intID_to_strID(0),
            receiver=user_from,
            receiverID=user_from_id,
            content=posts_json,
            service=ServiceType.BUILD_POST,
            type=MessageType.TEXT,
            timestamp=get_timestamp(),
        )
        return chatmsg

    def handle_loadUser_query(self, json_message):
        service_type = ServiceType(json_message.get("service", "none"))
        if service_type is not ServiceType.LOAD_USER:
            return

        user_from = json_message.get("sender", "")
        user_from_id = json_message.get("senderID", "")
        user_sendto = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        contentstr = json_message.get("content", "")

        # 查詢有 哪些用戶 並且全部用TUser轉成Json 丟到content
        jsondata = self.GetUserListJson()

        usersinfoMsg = ChatMsg(
            sender=self.hostname,
            senderID=intID_to_strID(0),
            receiver=user_from,
            receiverID=user_from_id,
            content=jsondata,
            service=ServiceType.LOAD_USER,
            type=MessageType.TEXT,
            timestamp=get_timestamp(),
        )

        return usersinfoMsg

    def GetUserListJson(self):
        users_data = []
        for user_info in self.user_info_list:
            # Assuming user_info has a .to_dict() method
            users_data.append(user_info.toJson())

        # 轉成 JSON 字串再用 Response 包起來
        return json.dumps(users_data, ensure_ascii=False)

    def get_client_count(self):
        return len(self.clients_SOCKET)

    def PrintHistory(self):
        print(self.client_histories)

    def SaveHistory(self, filename="Server/log/client_histories.json"):
        try:
            with open(filename, "w", encoding="utf-8") as f:
                json.dump(self.client_histories, f, ensure_ascii=False, indent=2)
            print(f"📝 歷史紀錄已儲存到 {filename}")
        except Exception as e:
            print(f"⚠️ 儲存歷史紀錄失敗: {e}")

    def _handle_aiReply_SYSTEM(self, userid, json_message):
        user_from = json_message.get("sender", "")
        AI_Agent = json_message.get("receiver")
        msg_type = MessageType(json_message.get("type", "text"))
        content = json_message.get("content", "")
        AI_Agent, _ = select_AImodel(AI_Agent)

        if ":" in content:
            command_name, command_value = content.split(":", 1)  # 只拆第一個冒號
        else:
            command_name = content
            command_value = ""

        if command_name == "SetCustomPrompt":
            if self.client_histories.get(userid) is None:
                self.client_histories[userid] = {}
            # 直接覆蓋為只有一個 system prompt
            self.client_histories[userid][AI_Agent] = [
                {"role": "system", "content": command_value}
            ]
            print(f"✅ 自訂 prompt 已套用於 {AI_Agent}：{command_value}")

        elif command_name == "Reset":
            if self.client_histories.get(userid) is None:
                self.client_histories[userid] = {}

            if AI_Agent not in self.client_histories[userid]:
                self.client_histories[userid][AI_Agent] = []

            self.client_histories[userid][AI_Agent] = [
                {"role": "system", "content": SYSTEM_PROMPT}
            ]

            print(
                f"✅ 已重置User: {user_from} 的 {AI_Agent}聊天紀錄。 system prompt為 :{SYSTEM_PROMPT}"
            )

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
                    return json.dumps(news_data, ensure_ascii=False)
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

    def GetUpdatePosts(self, amount: int, jsonpath: str = "Server/Posts.json"):
        need_update = True
        try:
            with open(jsonpath, "r", encoding="utf-8") as f:
                json_data = json.load(f)

            posts_data = json_data.get("posts")

            # ✅ 如果 post 是有效的 list 且有內容，就直接回傳
            if isinstance(posts_data, list) and len(posts_data) > 0:
                return json.dumps(posts_data, ensure_ascii=False)
        except FileNotFoundError:
            print(f"⚠️ 檔案 {jsonpath} 不存在，將重新取得資料")

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
            return jsondata
        else:
            print("找不到新聞")

    def listClients(self):
        if not self.clients_SOCKET:
            print("目前沒有連線的客戶端。")
            return

        print("目前連線的客戶端：")
        for key, value in self.clientslist.items():
            print("Key:", key)
            print("Value:", value)
            print("-" * 20)


def intID_to_strID(int_id, digit=4):
    return str(int_id).zfill(digit)


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
            Server = LuamaServer(ip, port)
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
            Server.listClients()
        elif cmd == "":
            pass
        elif cmd == "/log":
            pass

        else:
            Server.broadcast(cmd)

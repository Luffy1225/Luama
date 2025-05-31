import socket
import json
import datetime

from ..chatmsg import (
    ServiceType,
    MessageType,
    what_msg_type,
    get_timestamp,
    ChatMsg,
    chat_msg_to_string,
)


def main():
    host = "192.168.56.1"
    port = 50007

    # 建立 Socket 連線
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((host, port))
    print("🟢 已連線至伺服器：{0}:{1}".format(host, port))

    # 建立一筆要求新聞的 ChatMsg
    my_msg = ChatMsg(
        sender="ClientA",
        receiver="NewsServer",
        content="2",  # 要求回傳兩則新聞
        service=ServiceType.REQ_NEWS,  # 要求回傳兩則新聞
        type=MessageType.REQ_NEWS,
        timestamp=get_timestamp(),
    )

    # 將訊息轉為字串並送出
    msg_str = chat_msg_to_string(my_msg)
    print("📤 傳送訊息：{0}".format(msg_str))
    client.sendall(msg_str.encode("utf-8"))

    # 接收伺服器回應
    data = client.recv(4096)
    response = data.decode("utf-8")
    print("📥 伺服器回應：\n{0}".format(response))

    client.close()


if __name__ == "__main__":
    main()

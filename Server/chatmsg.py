import json
from enum import Enum
from datetime import datetime


class MessageType(Enum):
    TEXT = "text"
    IMAGE = "image"
    FILE = "file"
    TEXT_AND_FILE = "textAndFile"
    SYSTEM = "system"
    REQ_NEWS = "request_news"


class ServiceType(Enum):
    loginRegist = "loginRegist"
    SEND_USER_TO_USER = "send_user_to_user"
    AI_REPLY = "ai_reply"
    REQ_NEWS = "request_news"
    UPDATE_USER = "update_user"
    REQ_POST = "request_post"
    BUILD_POST = "build_post"
    LOAD_USER = "load_user"
    NONE = "none"


def what_msg_type(text: str, image: str = None) -> MessageType:
    has_text = bool(text)
    has_image = image is not None

    if has_text and has_image:
        return MessageType.TEXT_AND_FILE
    elif has_image:
        return MessageType.FILE
    else:
        return MessageType.TEXT


def get_timestamp() -> str:
    now = datetime.now()
    return now.strftime("%Y-%m-%d – %H:%M")


class ChatMsg:
    def __init__(
        self,
        sender: str,
        receiver: str,
        content: str,
        timestamp: str,
        service: ServiceType = ServiceType.NONE,
        type: MessageType = MessageType.TEXT,
        senderID: str = "",
        receiverID: str = "",
    ):
        self.sender = sender
        self.senderID = senderID
        self.receiver = receiver
        self.receiverID = receiverID
        self.service = service
        self.type = type
        self.content = content
        self.timestamp = timestamp

    def to_json(self) -> dict:
        return {
            "sender": self.sender,
            "senderID": self.senderID,
            "receiver": self.receiver,
            "receiverID": self.receiverID,
            "service": self.service.value,
            "type": self.type.value,
            "content": self.content,
            "timestamp": self.timestamp,
        }

    @staticmethod
    def from_json(json_data: dict):
        return ChatMsg(
            sender=json_data.get("sender", ""),
            senderID=json_data.get("senderID", ""),
            receiver=json_data.get("receiver", ""),
            receiverID=json_data.get("receiverID", ""),
            service=ServiceType(json_data.get("service", "none")),
            type=MessageType(json_data.get("type", "text")),
            content=json_data.get("content", ""),
            timestamp=json_data.get("timestamp", ""),
        )


def chat_msg_to_string(msg: ChatMsg) -> str:
    return json.dumps(msg.to_json(), ensure_ascii=False)


# if __name__ == "__main__":

# msg = ChatMsg(
#     sender="Me",
#     receiver="TargetUser",
#     content="Hello",
#     timestamp=get_timestamp(),
#     type=what_msg_type("Hello"),
# )
# print(chat_msg_to_string(msg))

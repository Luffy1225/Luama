import json
from enum import Enum
from datetime import datetime


class MessageType(Enum):
    TEXT = "text"
    IMAGE = "image"
    FILE = "file"
    TEXT_AND_FILE = "textAndFile"
    SYSTEM = "system"


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
        type: MessageType = MessageType.TEXT,
    ):
        self.sender = sender
        self.receiver = receiver
        self.type = type
        self.content = content
        self.timestamp = timestamp

    def to_json(self) -> dict:
        return {
            "sender": self.sender,
            "receiver": self.receiver,
            "type": self.type.value,
            "content": self.content,
            "timestamp": self.timestamp,
        }

    @staticmethod
    def from_json(json_data: dict):
        return ChatMsg(
            sender=json_data["sender"],
            receiver=json_data["receiver"],
            content=json_data["content"],
            timestamp=json_data["timestamp"],
            type=MessageType(json_data.get("type", "text")),
        )


def chat_msg_to_string(msg: ChatMsg) -> str:
    return json.dumps(msg.to_json(), ensure_ascii=False)


if __name__ == "__main__":
    msg = ChatMsg(
        sender="Me",
        receiver="TargetUser",
        content="Hello",
        timestamp=get_timestamp(),
        type=what_msg_type("Hello"),
    )
    print(chat_msg_to_string(msg))

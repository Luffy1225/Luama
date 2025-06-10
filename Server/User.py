import json

class TUser:

    def __init__(self, userID: str, userName: str, profileImage: str, email: str,  isAIAgent: bool, isOnline: bool = False):
        self.userID = userID
        self.userName = userName
        self.profileImage = profileImage
        self.email = email
        self.isAIAgent = isAIAgent 
        self.isOnline = isOnline

    def toJson(self) -> dict:        
        return {
            'userID': self.userID,
            'userName': self.userName,
            'profileImage': self.profileImage,
            'email': self.email,
            'isOnline': self.isOnline,
            'isAIAgent': self.isAIAgent, 
        }

# --- Example Usage ---
if __name__ == "__main__":
    # Create an instance of TUser
    user_example = TUser(
        userID="user_001",
        userName="Alice",
        profileImage="https://example.com/alice_profile.jpg",
        email="alice@example.com",
        isOnline=True
    )

    # Convert the TUser object to a JSON-compatible dictionary
    user_dict = user_example.toJson()
    print("User data as a Python dictionary:")
    print(user_dict)

    # Convert the dictionary to a JSON string for storage or transmission
    json_string = json.dumps(user_dict, indent=4, ensure_ascii=False)
    print("\nUser data as a formatted JSON string:")
    print(json_string)

    # You could also 'load' from a dictionary back into a TUser object
    # This is similar to your Dart 'readfromJson' method.
    reconstructed_user = TUser(
        userID=user_dict['userID'],
        userName=user_dict['userName'],
        profileImage=user_dict['profileImage'],
        email=user_dict['email'],
        isOnline=user_dict['isOnline']
    )
    print(f"\nReconstructed user's name: {reconstructed_user.userName}")
# Luama

Luama 是一款**基於 Socket TCP 架構**，並**整合大型語言模型（LLM）**的**多功能聊天軟體**，具備 AI 對話、用戶即時互動、新聞閱讀、貼文功能等，支援語音與文字雙向轉換，適用於 iOS 與 Android 跨平台使用。

[GitHub 專案連結](https://github.com/Luffy1225/Luama)  
[簡報連結（Gamma）](https://gamma.app/docs/Luama-lhcq85h82h0so3z)  
[Demo 影片](https://www.youtube.com/watch?v=MwaUEbr6dXo)

---

## 🔍 專案簡述

本專案使用 Flutter 開發，提供使用者一個可與 AI 進行對話、也能與其他使用者進行互動的 App。系統採用原生 Socket TCP 建構穩定的即時通訊架構，並支援擴充多種大型語言模型。

---

## 🎯 系統特點與目標

| 功能 | 說明 |
|------|------|
| 雙向互動 | 使用者與系統之間提供即時、順暢的問答介面 |
| 原生 Socket TCP | 強化資料傳輸穩定性與效率 |
| 多模型整合 | 支援 llama3、deepseek 等模型，未來可擴充更多模型 |
| 自訂 Prompt | 使用者可定義語言模型指令以彈性應用 |
| TTS（文字轉語音） | 增強語音互動體驗 |
| STT（語音轉文字） | 實現語音輸入功能 |
| iOS 與 Android 支援 | 跨平台無縫運行 |
| 支援深淺色模式 | 提供個人化外觀設定 |

---

## 🧩 主要功能模組

| 模組名稱 | 說明 |
|----------|------|
| AI 對談 | 整合語言模型產生回應 |
| AI 設定 | 提供角色 Prompt 設定與 AI 重置功能 |
| STT | 語音輸入轉文字 |
| TTS | 文字輸出為語音 |
| 新聞功能 | 即時擷取 ettoday 新聞資料供使用者閱讀 |
| 貼文功能 | 使用者可上傳、查看貼文 |
| 聊天功能 | 使用者間的私聊功能 |

---

## 📡 系統架構與原理

### 🔗 中心化架構

系統採用中央伺服器架構，所有 Client 間的資料傳遞皆透過 Server 進行管理與協調，通訊格式使用 JSON，具備以下優勢：

- 功能統一解析
- 易於擴充與維護
- 資料標準化

### 🧠 AI 模型整合

- 支援模型：`llama3.2:latest`、`deepseek-r1:7b`
- 可透過 `select_AImodel(model_name)` 擴充模型
- Server 保留所有使用者對話記憶，確保上下文連貫

### 🗣 語音處理（TTS / STT）

- STT、TTS 處理均在前端完成
- 前端將轉換後的文字傳送至 Server 處理

---

## 📰 新聞功能設計

- 使用者開啟新聞頁面時，App 發送 `Request_News` 給 Server
- Server 使用爬蟲抓取 [ETtoday](https://www.ettoday.net/) 新聞資料
- 若距上次更新時間小於 1 小時，則回傳快取資料，減輕 Server 負擔

---

## 📝 貼文功能設計

- 使用者開啟貼文頁面時，App 發送 `Request_Posts`
- Server 回傳本地貼文資料
- 建立新貼文時，發送 `Build_Posts` 請求，Server 寫入資料

---

## 💬 聊天功能設計

### 使用者註冊與識別

- App 初次連線時發送 `loginRegist` 的 `Chatmsg`，建立 User 與 Socket 對應關係
- Server 維護：
  - `user_info_list`：儲存所有使用者資訊
  - `clientslist`：以使用者 ID 為鍵、Socket 為值的字典

### 私訊傳遞機制

- App 發送訊息時，標註 `SEND_USER_TO_USER`
- Server 根據目標 ID，查找對應的 Socket 並進行轉發

---

## 🧵 Server 技術細節

- 使用多線程處理 Client 連線（`accept()`）
- 根據收到的 JSON `Chatmsg.Service` 判斷功能需求並處理
- 支援 AI 模型切換、TTS/STT、新聞、貼文與聊天等多種訊息類型

---

## 🔗 相關連結

- 📂 [GitHub 專案頁面](https://github.com/Luffy1225/Luama)
- 🎞 [Luama Demo 影片](https://www.youtube.com/watch?v=MwaUEbr6dXo)
- 📊 [簡報（Gamma）](https://gamma.app/docs/Luama-lhcq85h82h0so3z)

---

## 📌 使用技術

- 前端：Flutter（支援 iOS / Android）
- 後端：Python Socket TCP、多線程架構
- AI 模型：llama3、deepseek（可擴充）
- 語音功能：支援 TTS、STT
- 通訊格式：JSON

---

## 📢 聯絡資訊

作者：411285052 資工二 曾柏碩  
如有任何問題，歡迎在 GitHub 提出 Issue！


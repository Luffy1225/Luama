import requests
from bs4 import BeautifulSoup
import json
import os
import datetime


def Get_News(amount: int):
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
        if len(jsondata) >= amount:
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


# 範例使用
Get_News(5)

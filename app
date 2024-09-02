!pip install langchain

import os

os.environ["GOOGLE_CSE_ID"] = "<GOOGLE_CSE_ID>"
os.environ["GOOGLE_API_KEY"] = "<GOOGLE_API_KEY>"

from langchain.tools import Tool
from langchain_community.utilities import GoogleSearchAPIWrapper

search = GoogleSearchAPIWrapper()


def top5_results(query):
    return search.results(query, 3)


tool = Tool(
    name="Google Search Snippets",
    description="Search Google for recent results.",
    func=top5_results,
)

keyword="cricket"
s=tool.run(f"Latest news articles on {keyword}")
s

links = [item["link"] for item in s]
links

!pip install openai==0.28

import requests
from bs4 import BeautifulSoup
import re

def save_html_from_url(url, data):
  try:
    response = requests.get(url)
    response.raise_for_status()
    data=response.text
    soup = BeautifulSoup(data, 'html.parser')
    data=soup.get_text()
    delimiters = ['\r', '\n', '\t']
    for delimiter in delimiters:
      data = data.replace(delimiter, '')
    return data
  except requests.exceptions.RequestException:
    pass

import openai
openai.api_key = "<api_key>"

def get_completion(prompt, model="gpt-3.5-turbo"):
    messages = [{"role": "assistant", "content": prompt}]
    response = openai.ChatCompletion.create(
        model=model,
        messages=messages,
        temperature=0,
    )
    return response.choices[0].message["content"]

prompt = """
Your task is to generate a detailed summary of a news article and give it a title \

Summarize the transcription such a way that crucial details of the article is not missed out \

article:
"""

for i in links:
  text=save_html_from_url(i, "")
  if(text != None):
    output=get_completion((prompt+text), model="gpt-3.5-turbo")
    print(output)

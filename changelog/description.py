#!/usr/bin/python3

import os
import requests
import json

PR_API_URL = "https://git.eden-emu.dev/api/v1/repos/eden-emu/eden/pulls"
FORGEJO_NUMBER = os.getenv("FORGEJO_NUMBER")
FORGEJO_TOKEN = os.getenv("FORGEJO_TOKEN")

def get_pr_json():
    headers = {"Authorization": f"token {FORGEJO_TOKEN}"}
    response = requests.get(f"{PR_API_URL}/{FORGEJO_NUMBER}", headers=headers)
    return response.json()

def get_pr_description():
    try:
        pr_json = get_pr_json()
        return pr_json.get("body", "No changelog provided.")
    except:
        return "No changelog provided."

print(get_pr_description())
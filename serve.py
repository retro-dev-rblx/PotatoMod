import os
import time
import requests

public_server_url = "https://retrodliver.nicepotato.repl.co"  # Replace with the actual public server URL

filename = "v2.0.0.luau"

def monitor_and_upload():
    last_modified = 0
    while True:
        try:
            file_stat = os.stat(filename)
            if file_stat.st_mtime > last_modified:
                with open(filename, "r") as file:
                    data = file.read()
                    response = requests.put(public_server_url, data=data)
                    if response.status_code == 200:
                        print("Uploaded "+filename+" to the public server.")
                    else:
                        print("Failed to upload "+filename+" to the public server.")
                last_modified = file_stat.st_mtime
            time.sleep(0.2)  # Check every 5 seconds for changes
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    monitor_and_upload()

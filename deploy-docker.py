import os

changed = os.popen('git diff --name-only HEAD^').read()

for file in changed.split("\n"):
  if "docker/" in file:
    print(f">>> Updating: {file}")
    stack = file.split("/")[1].split(".")[0]
    os.system(f"docker stack deploy --detach=true {stack} -c {file}")
  else:
    print(f"<<< Not docker: {file}")

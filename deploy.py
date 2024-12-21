import os
import subprocess

changedFiles = subprocess.run("git diff --name-only".split(" "), stdout=subprocess.PIPE).stdout.decode().splitlines()
print(changedFiles)

for file in changedFiles:
    print(f"----------------------------------")
    print(f"changed file: {file}")
    if file.split("/")[0] == "stacks":
        print(f"is a docker stack")
        name = file.split("/")[-1].replace(".yml", "")
        if ".ignore" in name:
            print("--> ignoring")
            continue
        print(f"--> deploying")
        os.system("docker stack deploy {name} -c {file}")
    if file.split("/")[0] == "hosts":
        print(f"is a nixos config")
        name = file.split("/")[-1].replace(".nix", "")
        if ".ignore" in name:
            print("--> ignoring")
            continue
        print(f"--> cannot deploy, not implemented")
        # TODO: Implement nixos deploy
    else:
        print("is unknown")
        print("--> ignoring")
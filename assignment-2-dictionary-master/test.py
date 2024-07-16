import subprocess
import os

input_array = ["", "telegram", "whatsapp", "viber", "a" * 255, "1" * 257]
output_array = ["", "one of the best messengers ever", "your grandma messenger", "someone use it?", "", ""]
error_array = ["No words", "", "", "", "No words", "String is too long"]

errors = []

if os.path.exists("./main"):
    print("Starting test")

    for i in range(len(input_array)):
        process = subprocess.Popen(["./main"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate(input=input_array[i].encode())

        if (process.returncode == -11):
            print("F")
        else:
            stdout = stdout.decode().strip()
            stderr = stderr.decode().strip()

            if (stdout == output_array[i] and stderr == error_array[i]):
                print("_")
            else:
                print("F")
                if stdout != output_array[i]:
                    errors.append("Wrong output: " + stdout + ", expected " + output_array[i])
                if stderr != errors[i]:
                    errors.append("Wrong error: " + stderr + " expected " + error_array[i])

    print("\n")
    if len(errors) != 0:
        for string in errors:
            print(string)
    else:
        print("All tests are passed")
else:
    print("Executable file \"main\" does not exist")


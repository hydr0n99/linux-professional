import time

start = time.time()

i = 0
while i < 1_000_000_000:
#while True:
    i += 1

print(f"run_me_2 duration {round(time.time() - start, 2)}")

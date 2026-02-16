import random

letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
size = 500_000_000
random_string = ''.join(random.choices(letters, k=size))

with open("large_file.txt", "w") as f:
    f.write(random_string)

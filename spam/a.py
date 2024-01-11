
import random
import string

def generate_4_digit_codes(count=50):
    return [''.join(random.choices(string.ascii_uppercase + string.digits, k=4)) for _ in range(count)]

def save_codes_to_file(filename, codes):
    with open(filename, 'w') as file:
        for code in codes:
            file.write(code + '\n')

# Generate codes
codes = generate_4_digit_codes(1000)

# Save to a file
save_codes_to_file('random_codes.txt', codes)

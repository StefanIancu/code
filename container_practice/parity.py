print("Hello world!")

# i am editing this to check if github is working 

# seems like this is working 
# on macccc, check on windows then


def parity():
    x = input("Input number to check parity: ")
    if x.isdigit():
        if int(x) % 2 == 0:
            print(f"{x} is a round number!")
        else:
            print(f"{x} is not a round number.")
    else:
        print("That's not a digit.")

parity()
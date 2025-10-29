def buggyfunc(x):
    y = x
    for i in range(x):
        try:
            y = y - 1
            z = x / y
        except ZeroDivisionError:
            print("Division by zero is undefined.")
        except:
            print("An unexpected error occurred.x={x},y={y}")
        else:
            print(f"successfully run x={x}, y={y}, z={z}")      
    return z
buggyfunc(20)

x = 10
print(f"{x = }")

from math import cos, radians
theta = 30
print(f"{theta = }, {cos(radians(theta)) = :.3f}")

from abc import ABC, abstractmethod

class Vehicle(ABC):
    @abstractmethod
    def drive(self) -> str:
        pass

class Car(Vehicle):
    def drive(self) -> str:
        return "Driving a sleek, fast car!"

class Bike(Vehicle):
    def drive(self) -> str:
        return "Riding a sporty motor bike!"

class VehicleFactory:
    @staticmethod
    def get_vehicle(vehicle_type: str) -> Vehicle:
        if vehicle_type.lower() == "car":
            return Car()
        elif vehicle_type.lower() == "bike":
            return Bike()
        else:
            raise ValueError(f"Unknown vehicle type: {vehicle_type}")

if __name__ == "__main__":
    try:
        my_car = VehicleFactory.get_vehicle("car")
        print(my_car.drive())
        my_bike = VehicleFactory.get_vehicle("bike")
        print(my_bike.drive())
    except ValueError as e:
        print(e)
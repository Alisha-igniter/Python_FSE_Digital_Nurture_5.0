class Singleton:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super().__new__(cls)
        return cls._instance

if __name__ == "__main__":
    s1 = Singleton()
    s2 = Singleton()
    print(f"Object 1 ID: {id(s1)}")
    print(f"Object 2 ID: {id(s2)}")
    print(f"Are both instances the same? {s1 is s2}")
def binary_search(arr: list, target: int) -> int:
    low = 0
    high = len(arr) - 1

    while low <= high:
        mid = (low + high) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1

if __name__ == "__main__":
    sorted_list = [10, 23, 35, 47, 50, 68, 72, 89, 94]
    search_target = 47
    result = binary_search(sorted_list, search_target)
    print(f"Target {search_target} found at index: {result}")
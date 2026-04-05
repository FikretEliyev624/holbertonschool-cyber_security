#!/usr/bin/python3
"""
Write a script that finds a string in the heap of a running process,
and replaces it.
"""
import sys


def read_write_heap():
    """
    Finds and replaces a string in the heap of a running process.
    """
    if len(sys.argv) != 4:
        print("Usage: read_write_heap.py pid search_string replace_string")
        sys.exit(1)

    pid = sys.argv[1]
    search_string = sys.argv[2]
    replace_string = sys.argv[3]

    try:
        # 1. Read the maps file to find the heap location
        with open(f"/proc/{pid}/maps", "r") as maps_file:
            heap_info = None
            for line in maps_file:
                if "[heap]" in line:
                    heap_info = line
                    break

            if not heap_info:
                print(f"[ERROR] Heap not found for PID {pid}")
                sys.exit(1)

            parts = heap_info.split()
            addr_range = parts[0].split("-")
            start_addr = int(addr_range[0], 16)
            end_addr = int(addr_range[1], 16)

        # 2. Open the mem file and perform the replacement
        with open(f"/proc/{pid}/mem", "rb+") as mem_file:
            mem_file.seek(start_addr)
            heap = mem_file.read(end_addr - start_addr)

            try:
                offset = heap.index(bytes(search_string, "ascii"))
            except ValueError:
                print(f"[ERROR] String '{search_string}' not found")
                sys.exit(1)

            # Execution of the writing process
            mem_file.seek(start_addr + offset)
            # Writing the replacement string with a null terminator
            mem_file.write(bytes(replace_string + '\0', "ascii"))

    except Exception as e:
        print(f"[ERROR] {e}")
        sys.exit(1)


if __name__ == "__main__":
    read_write_heap()

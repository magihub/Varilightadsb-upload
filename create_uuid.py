import os
import uuid

uuid_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'UUID')

if os.path.exists(uuid_file):
    with open(uuid_file, 'r') as file_object:
        mid = file_object.read().strip()
else:
    mid = str(uuid.uuid1().hex)[16:]
    with open(uuid_file, 'w') as file_object:
        file_object.write(mid)

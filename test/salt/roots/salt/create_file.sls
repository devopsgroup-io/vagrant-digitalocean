create_directory:
  file.directory:
    - name: /tmp/folders
    - makedirs: True
    - dir_mode: 777
    - file_mode: 666
    - recurse:
      - mode

create_file:
  file.managed:
    - name: /tmp/folder/file_from_salt
    - mode: 666
    - contents: some text
    - require:
      - file: create_directory


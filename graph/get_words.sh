echo 'select words.word from line_words join words on words.word_id = line_words.word_id where song_id = 19 order by line_words.num_word_in_song' | /Applications/Postgres.app/Contents/MacOS/bin/psql -t -U postgres > SqWrliMzrW8.txt
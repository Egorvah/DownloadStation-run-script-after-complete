#!/bin/sh

if [[ $1 = "install" ]]; then
	echo 'Installing...'

	SQL=$(cat <<-END
		DROP TABLE IF EXISTS "download_noty";
		DROP TRIGGER IF EXISTS "onComplete" ON download_queue;
		DROP FUNCTION IF EXISTS AddDownloadedNoty();

		create table download_noty (
			task_id SERIAL,
			url text,
			filename varchar(1024),
			status int,
			created_at TIMESTAMP DEFAULT now() NOT NULL
		);
		CREATE UNIQUE INDEX download_noty_task_id_uindex ON download_noty (task_id);

		CREATE OR REPLACE FUNCTION AddDownloadedNoty()
		RETURNS TRIGGER AS
		\$BODY$
		BEGIN

		INSERT INTO download_noty(task_id, url, filename, status) VALUES (new.task_id, new.url, new.filename, new.status);

		RETURN new;

		END;
		\$BODY$ 
		LANGUAGE plpgsql;


		CREATE TRIGGER "onComplete"
		AFTER UPDATE OF status ON download_queue
		FOR EACH ROW WHEN (new.status = 5 or new.status = 8)
		EXECUTE PROCEDURE AddDownloadedNoty();
	END
	)

	eval "psql -t -A -U postgres -d download -c '$SQL'"
fi

if [[ -z "$1" ]]; then
	DL_SQL_RESULT=$(psql -t -A -U postgres -d download -c 'SELECT task_id, url FROM download_noty')

	for DL_DATA in $(echo $DL_SQL_RESULT)
	do
		TASK_ID=$(echo $DL_DATA 2>&1 | head -n 1 | cut -d "|" -f 1)
		FILE=$(echo $DL_DATA 2>&1 | head -n 1 | cut -d "|" -f 2)
		echo $TASK_ID
		echo $FILE
		# Start your algorithm
		# For example send message to telegram bot
		wget  "https://api.telegram.org/bot{token}/sendMessage?chat_id={chat_id}&parse_mode=html&text=Download complete: $FILE"
		eval "psql -t -A -U postgres -d download -c 'DELETE FROM download_noty WHERE task_id = $TASK_ID'"
	done
fi

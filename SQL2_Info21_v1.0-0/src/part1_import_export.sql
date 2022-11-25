CREATE OR REPLACE PROCEDURE pr_export_table_to_csv(file_name varchar(255),
                                                   table_name varchar(255),
                                                   separator varchar(4))
    LANGUAGE plpgsql
AS
$$
DECLARE
    execute_str varchar(510);
    path_file   varchar(255) := (SELECT setting AS directory
                                 FROM pg_settings
                                 WHERE name = 'data_directory') || '/' || file_name;
BEGIN
    execute_str := 'copy (select * from ' || table_name || ') to ''' || path_file || ''' delimiter ''' || separator ||
                   ''' csv header';
    EXECUTE (execute_str);
END;
$$;

-- call pr_export_table_to_csv('peers.csv', 'peers', ',');

CREATE OR REPLACE PROCEDURE pr_import_table_from_csv(file_name varchar(255),
                                                     table_name varchar(255),
                                                     separator varchar(4))
    LANGUAGE plpgsql
AS
$$
DECLARE
    execute_str varchar(510);
    path_file   varchar(255) := (SELECT setting AS directory
                                 FROM pg_settings
                                 WHERE name = 'data_directory') || '/' || file_name;
BEGIN
    execute_str := 'copy ' || table_name || ' from ''' || path_file || ''' delimiter ''' || separator ||
                   ''' csv header';
    EXECUTE (execute_str);
END;
$$;

-- call pr_import_table_from_csv('peers.csv', 'peers', ',');
*! version 0.0.1  12jun2020

program define getmariadb
	version 16
	syntax [anything], [server(string) database(string) user(string) pswd(string) sql(string)]

    clear
    javacall com.leam.stata.getmariadb.StataMariaDB getData, jars(getmariadb.jar) args(`"`server'"' `"`database'"' `"`user'"' `"`pswd'"' `"`sql'"')
    compress
end

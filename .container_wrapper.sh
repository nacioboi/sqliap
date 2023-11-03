sudo docker run -d -p 3306:3306 -p 3000:3000 --name=mysqldc --mount source=mysqldv,target=/var/lib/mysql mysqldi &&

# delete container on exit.
trap "sudo docker rm --force my-mysql" EXIT

read -p "Would you like to enter the container? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo docker exec -it mysqldc bash
fi
postgres:
	docker run --name postgres12 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:latest

simplebank:
	docker run --name simplebank -p 8080:8080 simplebank

createdb:
	docker exec -it postgres12 createdb --username=root --owner=root simple_bank
dropdb:
	docker exec -it postgres12 dropdb simple_bank
migrateup:
	migrate -path db/migration -database "postgresql://root:Qhir$4gf@simple-bank.cvuq1fntl3rr.ap-northeast-2.rds.amazonaws.com:5432/postgres" -verbose up

migrateup1:
	migrate -path db/migration -database "postgresql://root:Qhir$4gf@simple-bank.cvuq1fntl3rr.ap-northeast-2.rds.amazonaws.com:5432/postgres" -verbose up 1

migratedown:
	migrate -path db/migration -database "postgresql://root:Qhir$4gf@simple-bank.cvuq1fntl3rr.ap-northeast-2.rds.amazonaws.com:5432/postgres" -verbose down

migratedown1:
	migrate -path db/migration -database "postgresql://root:Qhir$4gf@simple-bank.cvuq1fntl3rr.ap-northeast-2.rds.amazonaws.com:5432/postgres" -verbose down 1

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/spacex81/simplebank/db/sqlc Store
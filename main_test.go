package main

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5"
)

var tables = []string{
	"highways",
	"buildings",
	"water",
	"landuse",
	"places",
	"boundaries",
}

func TestTablesHaveRows(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Skip("TEST_DATABASE_URL not set")
	}

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, url)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer conn.Close(ctx)

	for _, table := range tables {
		t.Run(table, func(t *testing.T) {
			var n int64
			err := conn.QueryRow(ctx, "SELECT count(*) FROM "+table).Scan(&n)
			if err != nil {
				t.Fatalf("query %s: %v", table, err)
			}

			if n == 0 {
				t.Fatalf("table %s is empty", table)
			}

			t.Logf("rows in %s: %d", table, n)
		})
	}
}

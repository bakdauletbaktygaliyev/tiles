package main

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/jackc/pgx/v5"
)

func TestHighwaysLoad(t *testing.T) {
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

	var n int64
	err = conn.QueryRow(ctx, "SELECT count(*) FROM highways").Scan(&n)
	if err != nil {
		t.Fatalf("query: %v", err)
	}

	if n == 0 {
		t.Fatal("expected highways, got none")
	}

	fmt.Println("Rows in highways table: ", n)
}

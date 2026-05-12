import os
import pandas as pd
from google.cloud import bigquery
from dotenv import load_dotenv

load_dotenv()

PROJECT_ID = os.getenv("BQ_PROJECT_ID")
DATASET    = os.getenv("BQ_DATASET")
DATA_DIR   = os.path.join(os.path.dirname(__file__), "..", "data", "olist_data")

FILES = {
    "olist_orders_dataset.csv":         "raw_orders",
    "olist_customers_dataset.csv":      "raw_customers",
    "olist_products_dataset.csv":       "raw_products",
    "olist_order_items_dataset.csv":    "raw_order_items",
    "olist_order_payments_dataset.csv": "raw_order_payments",
    "olist_order_reviews_dataset.csv":  "raw_order_reviews",
}

def get_client():
    return bigquery.Client(project=PROJECT_ID)

def create_dataset_if_not_exists(client):
    dataset_ref = f"{PROJECT_ID}.{DATASET}"
    try:
        client.get_dataset(dataset_ref)
        print(f"Dataset {DATASET} existe déjà.")
    except Exception:
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = "US"
        client.create_dataset(dataset)
        print(f"Dataset {DATASET} créé.")

def load_csv_to_bigquery(client, csv_filename, table_name):
    filepath = os.path.join(DATA_DIR, csv_filename)

    if not os.path.exists(filepath):
        print(f"  [SKIP] Fichier introuvable : {csv_filename}")
        return

    print(f"  Lecture de {csv_filename}...")
    df = pd.read_csv(filepath, low_memory=False)
    df.columns = [col.lower() for col in df.columns]
    df = df.where(pd.notnull(df), None)

    table_ref = f"{PROJECT_ID}.{DATASET}.{table_name}"
    job_config = bigquery.LoadJobConfig(write_disposition="WRITE_TRUNCATE")

    print(f"  Chargement de {len(df):,} lignes → {table_name}...")
    job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()

    print(f"  OK — {len(df):,} lignes insérées dans {table_name}")

def main():
    print("Connexion à BigQuery...")
    client = get_client()
    print("Connecté !\n")

    create_dataset_if_not_exists(client)
    print()

    for csv_file, table in FILES.items():
        print(f"--- {table.upper()} ---")
        load_csv_to_bigquery(client, csv_file, table)
        print()

    print("Chargement terminé.")

if __name__ == "__main__":
    main()

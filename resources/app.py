import tkinter as tk
from tkinter import ttk, simpledialog, messagebox
import psycopg2
import datetime
import base64

class DatabaseApp:
    def __init__(self, master):
        self.master = master
        self.master.title("Aplikacija za praćenje i pomoć u održavanju rasta biljke")

        self.master.state("zoomed")

        self.prikazi_sve_biljke_button = tk.Button(master, text="Sve biljke", command=self.prikazi_sve_biljke, font=('Helvetica', 16))
        self.prikazi_sve_biljke_button.pack(pady=10)

        self.prikazi_moje_biljke_button = tk.Button(master, text="Moje biljke", command=self.prikazi_moje_biljke, font=('Helvetica', 16))
        self.prikazi_moje_biljke_button.pack(pady=10)

        self.istraz_detalje_button = tk.Button(master, text="Istrazi detalje", command=self.istraz_detalje, font=('Helvetica', 16))
        self.istraz_detalje_button.pack(pady=10)

        self.master.protocol("WM_DELETE_WINDOW", self.on_close)

        self.db_params = {
            'host': 'localhost',
            'port': 5432,
            'user': 'postgres',
            'password': '2829',
            'database': 'TBP-Projekt',
        }

    def prikazi_sve_biljke(self):
        detalji_biljke = self.ucitaj_detalje_svih_biljki()

        for widget in self.master.winfo_children():
            widget.destroy()

        tree = ttk.Treeview(self.master)
        tree["columns"] = ("col0", "col1", "col2", "col3", "col4", "col5", "col6", "col7")
        tree["show"] = "headings"

        column_headings = [
            "NAZIV BILJKE", "MAKSIMALNA VELICINA BILJKE", "UCESTALOST ZALIJEVANJA", "UCESTALOST REZANJA", "BOJA LISTA", "VELICINA LISTA", "BOJA CVIJETA", "VELICINA CVIJETA"
        ]

        for i, col in enumerate(tree["columns"]):
            tree.heading(col, text=column_headings[i])
            
        for row_data in detalji_biljke:
            tree.insert("", "end", values=row_data)

        tree.pack()

        nazad_button = tk.Button(self.master, text="Nazad", command=self.pocetni_zaslon, font=('Helvetica', 16))
        nazad_button.pack(pady=10)

    def ucitaj_detalje_svih_biljki(self):
        try:
            connection = psycopg2.connect(**self.db_params)

            with connection.cursor() as cursor:
                cursor.callproc("DetaljiSvihBiljki")
                detalji_svih_biljki_data = cursor.fetchall()

            return detalji_svih_biljki_data

        except psycopg2.Error as e:
            simpledialog.messagebox.showerror("Error", f"\n{e}")
            return []

        finally:
            if connection:
                connection.close()

    def prikazi_moje_biljke(self):
        moje_biljke = self.ucitaj_moje_biljke("MojeBiljke")

        for widget in self.master.winfo_children():
            widget.destroy()

        self.biljka_id = {}

        for i, row_data in enumerate(moje_biljke):
            self.biljka_id[i] = row_data[0]

            # Check if there is image data
            image_data = row_data[2]

            if isinstance(image_data, int):
                # Handle the case where image_data is an integer (assumed to be an OID)
                image_data = self.retrieve_image_data(image_data)

            try:
                # If there is image data, display it using a label
                if image_data:
                    # Retrieve bytea data directly
                    decoded_data = base64.b64decode(image_data)

                    # Display the image using a label
                    label = tk.Label(self.master)
                    label.photo = tk.PhotoImage(data=decoded_data)
                    label.config(image=label.photo)
                    label.pack(pady=5)
                else:
                    # If there is no image data, create a label with the text "Nema slike" (meaning "No image")
                    no_image_label = tk.Label(self.master, text="Nema slike", font=('Helvetica', 10))
                    no_image_label.pack(pady=5)

            except Exception as e:
                # If there's an exception during decoding or image creation, print the error
                print(f"Error creating image: {e}")

            self.biljka_id[i] = row_data[0]

            zali_button = tk.Button(self.master, text="Zali biljku", command=lambda plant=row_data[0]: self.zali_biljku(plant))
            zali_button.pack(pady=5)

            izrezi_button = tk.Button(self.master, text="Izrezi biljku", command=lambda plant=row_data[0]: self.izrezi_biljku(plant))
            izrezi_button.pack(pady=5)

        separator_label = tk.Label(self.master, text="----------- Povijest brige biljaka -----------", font=('Helvetica', 10, 'bold'))
        separator_label.pack(pady=10)

        # Display history using another Treeview
        tree = ttk.Treeview(self.master)
        tree["columns"] = ("col0", "col1", "col2")
        tree["show"] = "headings"

        column_headings = [
            "NAZIV BILJKE", "DATUMI ZALIJEVANJA", "DATUMI REZANJA"
        ]

        detalji_brige_biljaka = self.ucitaj_detalji_brige_biljaka()

        for i, col in enumerate(tree["columns"]):
            tree.heading(col, text=column_headings[i])
            
        for row_data in detalji_brige_biljaka:
            tree.insert("", "end", values=row_data)

        tree.pack()

        nazad_button = tk.Button(self.master, text="Nazad", command=self.pocetni_zaslon, font=('Helvetica', 16))
        nazad_button.pack(pady=10)

    def ucitaj_detalji_brige_biljaka(self):
        try:
            connection = psycopg2.connect(**self.db_params)

            with connection.cursor() as cursor:
                cursor.callproc("DetaljiBrigeBiljaka")
                detalji_svih_biljki_data = cursor.fetchall()

            return detalji_svih_biljki_data

        except psycopg2.Error as e:
            simpledialog.messagebox.showerror("Error", f"\n{e}")
            return []

        finally:
            if connection:
                connection.close()

    def retrieve_image_data(self, image_oid):
        try:
            connection = psycopg2.connect(**self.db_params)

            with connection.cursor() as cursor:
                # Retrieve bytea data directly
                cursor.execute("SELECT slika FROM MojeBiljke WHERE slika = %s", (image_oid,))
                result = cursor.fetchone()

                # Extract bytea data
                if result:
                    image_data = result[0]
                    return image_data

        except psycopg2.Error as e:
            print(f"Error retrieving image data: {e}")

        finally:
            if connection:
                connection.close()

        return None
    
    def zali_biljku(self, biljka_id):
            try:
                connection = psycopg2.connect(**self.db_params)

                current_date = datetime.date.today()

                with connection.cursor() as cursor:
                    cursor.execute(
                        "INSERT INTO brigamojebiljke (id_moje_biljke, datumzalijevanja) VALUES (%s, %s)",
                        (biljka_id, current_date)
                    )

                connection.commit()

                messagebox.showinfo("Info", f"Zalivena biljka s ID-em: {biljka_id}")

            except psycopg2.Error as e:
                simpledialog.messagebox.showerror("Error", f"\n{e}")

            finally:
                if connection:
                    connection.close()

    def izrezi_biljku(self, biljka_id):
        try:
            connection = psycopg2.connect(**self.db_params)

            current_date = datetime.date.today()

            with connection.cursor() as cursor:
                cursor.execute(
                    "UPDATE brigamojebiljke SET datumrezanja = %s WHERE id_moje_biljke = %s OR datumrezanja IS NULL",
                    (current_date, biljka_id)
                )

            connection.commit()

            messagebox.showinfo("Info", f"Izrezana biljka s ID-em: {biljka_id}")

        except psycopg2.Error as e:
            simpledialog.messagebox.showerror("Error", f"\n{e}")

        finally:
            if connection:
                connection.close()

    def ucitaj_moje_biljke(self, tablica_naziv):
        try:
            connection = psycopg2.connect(**self.db_params)

            with connection.cursor() as cursor:
                cursor.execute(f"SELECT * FROM {tablica_naziv}")
                table_data = cursor.fetchall()

            return table_data

        except psycopg2.Error as e:
            simpledialog.messagebox.showerror("Error", f"\n{e}")
            return []

        finally:
            if connection:
                connection.close()

    def istraz_detalje(self):
        detalji_window = tk.Toplevel(self.master)
        detalji_window.title("Istrazi detalje")

        naziv_biljke_unos = tk.Entry(detalji_window, font=('Helvetica', 12))
        naziv_biljke_unos.grid(row=0, column=0, padx=10, pady=10)

        search_button = tk.Button(detalji_window, text="Search", command=lambda: self.prikazi_detalje_jedne_biljke(naziv_biljke_unos.get()))
        search_button.grid(row=0, column=1, padx=10, pady=10)

    def prikazi_detalje_jedne_biljke(self, naziv_biljke):
        detalji_planta = self.ucitaj_detalje_jedne_biljke(naziv_biljke)

        detalji_window = tk.Toplevel(self.master)
        detalji_window.title(f"Detalji biljke - {naziv_biljke}")

        tree = ttk.Treeview(detalji_window)
        tree["columns"] = ("col0", "col1", "col2", "col3", "col4", "col5", "col6")
        tree["show"] = "headings"

        column_headings = [
            "MAKSIMALNA VELICINA BILJKE", "UCESTALOST ZALIJEVANJA", "UCESTALOST REZANJA", "BOJA LISTA", "VELICINA LISTA", "BOJA CVIJETA", "VELICINA CVIJETA"
        ]

        for i, col in enumerate(tree["columns"]):
            tree.heading(col, text=column_headings[i])

        for row_data in detalji_planta:
            tree.insert("", "end", values=row_data)

        tree.pack()

    def ucitaj_detalje_jedne_biljke(self, plant_name):
        try:
            connection = psycopg2.connect(**self.db_params)

            with connection.cursor() as cursor:
                cursor.callproc("DetaljiBiljke", [plant_name])
                detalji_planta_data = cursor.fetchall()

            return detalji_planta_data

        except psycopg2.Error as e:
            simpledialog.messagebox.showerror("Error", f"\n{e}")
            return []

        finally:
            if connection:
                connection.close()

    def pocetni_zaslon(self):
        for widget in self.master.winfo_children():
            widget.destroy()

        self.prikazi_sve_biljke_button = tk.Button(self.master, text="Sve biljke", command=self.prikazi_sve_biljke, font=('Helvetica', 16))
        self.prikazi_sve_biljke_button.pack(pady=10)

        self.prikazi_moje_biljke_button = tk.Button(self.master, text="Moje biljke", command=self.prikazi_moje_biljke, font=('Helvetica', 16))
        self.prikazi_moje_biljke_button.pack(pady=10)

        self.istraz_detalje_button = tk.Button(self.master, text="Istrazi detalje", command=self.istraz_detalje, font=('Helvetica', 16))
        self.istraz_detalje_button.pack(pady=10)
        

    def on_close(self):
        self.master.destroy()

def main():
    root = tk.Tk()
    app = DatabaseApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()

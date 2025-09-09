import os
import tkinter as tk
from tkinter import filedialog
import subprocess

def convertir_cur_en_png(fichier_cur, dossier_sortie):
    try:
        nom_sans_ext = os.path.splitext(os.path.basename(fichier_cur))[0]
        chemin_sortie = os.path.join(dossier_sortie, nom_sans_ext + ".png")
        os.makedirs(dossier_sortie, exist_ok=True)

        # Utilise 'magick' pour convertir
        cmd = ["magick", fichier_cur, chemin_sortie]
        print(f"Conversion de {fichier_cur} → {chemin_sortie} ...")
        subprocess.run(cmd, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"[ERREUR] La commande a échoué : {e}")
    except Exception as e:
        print(f"[ERREUR] Exception inattendue : {e}")

def parcourir_et_convertir(dossier_source, dossier_sortie):
    nb_convertis = 0
    for racine, _, fichiers in os.walk(dossier_source):
        for fichier in fichiers:
            if fichier.lower().endswith(".cur"):
                chemin_cur = os.path.join(racine, fichier)
                relative_path = os.path.relpath(racine, dossier_source)
                destination = os.path.join(dossier_sortie, relative_path)
                convertir_cur_en_png(chemin_cur, destination)
                nb_convertis += 1
    print(f"\n✅ {nb_convertis} fichiers .cur convertis en .png")

def choisir_dossier(titre):
    root = tk.Tk()
    root.withdraw()
    return filedialog.askdirectory(title=titre)

if __name__ == "__main__":
    print("📂 Choisis le dossier contenant les fichiers .cur :")
    dossier_source = choisir_dossier("Sélectionne le dossier source (.cur)")
    if not dossier_source:
        print("❌ Aucun dossier source sélectionné.")
        exit()

    dossier_sortie = choisir_dossier("Sélectionne le dossier de sortie (.png)")
    if not dossier_sortie:
        print("❌ Aucun dossier de sortie sélectionné.")
        exit()

    parcourir_et_convertir(dossier_source, dossier_sortie)
    input("\n🔚 Appuie sur Entrée pour quitter...")

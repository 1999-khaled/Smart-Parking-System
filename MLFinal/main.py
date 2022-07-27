import numpy as np
import pandas as pd
import pyrebase

config = {
    "apiKey": "AIzaSyBR8Aa517A9PjaHoBphSVJgiGs_7745HyQ",
    "authDomain": "modeltest-be734.firebaseapp.com",
    "databaseURL": "https://modeltest-be734-default-rtdb.firebaseio.com/",
    "storageBucket": "modeltest-be734.appspot.com"
}
def lmao():
    while (True):
        str_input = db.child("slots/1/x").get().val()
        long = float(str_input.split(",")[0])
        lat = float(str_input.split(",")[1])

        if long != 0 and lat != 0:
            sum = long + lat
            print(sum)
            db.child("slots/1").child("recommended_slot").set(sum)
            db.child("slots/1").child("x").set("0,0")
        else:
            print("0")


firebase = pyrebase.initialize_app(config)
db = firebase.database()
dataset = pd.read_csv(r"C:\Users\KHALED ZAKARIA\OneDrive\Desktop\bookkkkk.csv")
X = dataset.iloc[:, [1, 2]].values
print(X)
y = dataset.iloc[:, 0].values

def dist(x, X):
    return np.sqrt(np.sum((x - X) ** 2))


def knn(X, Y, x, k=7):
    m = X.shape[0]
    vals = []
    for i in range(m):
        d = dist(x, X[i])
        vals.append((d, Y[i]))
    vals = sorted(vals, key=lambda x: x[0])[:k]
    vals = np.asarray(vals)
    new_vals = np.unique(vals[:, 1], return_counts=True)
    index = new_vals[1].argmax()
    pred = new_vals[0][index]
    output=vals[0]
    res = output.astype(str)
    print(res[1])

    return pred


if __name__ == "__main__":
   x=[34.7657,34.1268]
   knn(X,y,x)
   lmao()

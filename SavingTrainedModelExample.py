import pickle

knnPickle = open('baggedwknnpicklefile','wb')
pickle.dump(bagging_model,knnPickle)
knnPickle.close()

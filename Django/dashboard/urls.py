# myapp/urls.py

from django.urls import path
from .views import home, graphs, user

urlpatterns = [
    path('', home, name='home'), 
    path('graphs/', graphs, name='graphs'),
    path('user/', user, name='user'),
]

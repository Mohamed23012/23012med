from django.urls import path
from .views import InsertDataView,SearchByOperatorView, SearchByLocationView

urlpatterns = [
    path('insert_data/', InsertDataView.as_view(), name='insert_data'),
    path('search-by-operator/', SearchByOperatorView.as_view(), name='search-by-operator'),
    path('search-by-location/', SearchByLocationView.as_view(), name='search-by-location')
]


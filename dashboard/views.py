from django.shortcuts import render

def dashboard_view(request):
    return render(request, 'dashboard.html')

def home(request):
    return render(request, 'home.html')

def graphs(request):
    return render(request, 'graphs.html')

def user(request):
    return render(request, 'user.html')
"""
URL configuration for notification service.
"""
from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

def health_check(request):
    """Simple health check endpoint"""
    return HttpResponse("OK", content_type="text/plain")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health_check'),
] 
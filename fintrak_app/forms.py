from django import forms
from .models import Transaction, Report

class TransactionForm(forms.ModelForm):
    class Meta:
        model = Transaction
        fields = ['userid', 'amount', 'category', 'date']

class ReportForm(forms.ModelForm):
    class Meta:
        model = Report
        fields = ['startdate', 'enddate']
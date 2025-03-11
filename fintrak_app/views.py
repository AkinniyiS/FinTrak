from django.shortcuts import render, redirect
from django.utils import timezone
from .models import Transaction, Budget, Report
from .forms import TransactionForm, ReportForm

def transaction_list(request):
    transactions = Transaction.objects.all()
    return render(request, 'fintrak_app/transaction_list.html', {'transactions': transactions})

def budget_list(request):
    budgets = Budget.objects.all()
    return render(request, 'fintrak_app/budget_list.html', {'budgets': budgets})

def report_list(request):
    reports = Report.objects.all()
    return render(request, 'fintrak_app/report_list.html', {'reports': reports})

def report_create(request):
    if request.method == 'POST':
        form = ReportForm(request.POST)
        if form.is_valid():
            report = form.save(commit=False)
            report.userid_id = 1  # Hardcode for now
            report.generatereport = timezone.now()
            # Set full-day ranges
            report.startdate = report.startdate.replace(hour=0, minute=0, second=0, microsecond=0)
            report.enddate = report.enddate.replace(hour=23, minute=59, second=59, microsecond=999999)
            report.save()
            return redirect('report_list')
    else:
        form = ReportForm()
    return render(request, 'fintrak_app/report_form.html', {'form': form})

def report_detail(request, report_id):
    report = Report.objects.get(reportid=report_id)
    transactions = Transaction.objects.filter(date__range=[report.startdate, report.enddate])
    return render(request, 'fintrak_app/report_detail.html', {
        'report': report,
        'transactions': transactions
    })
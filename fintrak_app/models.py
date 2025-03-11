# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Budget(models.Model):
    budgetid = models.AutoField(db_column='budgetID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey('User', models.DO_NOTHING, db_column='userid', blank=True, null=True)
    category = models.CharField(max_length=255, blank=True, null=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    setbudget = models.DateTimeField(blank=True, null=True)
    updatebudget = models.DateTimeField(blank=True, null=True)
    checkbudget = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Budget'


class Report(models.Model):
    reportid = models.AutoField(db_column='reportID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey('User', models.DO_NOTHING, db_column='userid', blank=True, null=True)
    startdate = models.DateTimeField(db_column='startDate', blank=True, null=True)  # Field name made lowercase.
    enddate = models.DateTimeField(db_column='endDate', blank=True, null=True)  # Field name made lowercase.
    generatereport = models.DateTimeField(db_column='generateReport', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Report'


class Transaction(models.Model):
    transactionid = models.AutoField(db_column='transactionID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey('User', on_delete=models.CASCADE, db_column='userid', blank=True, null=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.CharField(max_length=255, blank=True, null=True)
    date = models.DateTimeField(blank=True, null=True)
    addtransaction = models.DateTimeField(blank=True, null=True)
    edittransaction = models.DateTimeField(blank=True, null=True)
    deletetransaction = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Transaction'


class User(models.Model):
    userid = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)
    email = models.CharField(unique=True, max_length=255)
    password = models.CharField(max_length=255)
    register = models.DateTimeField(blank=True, null=True)
    login = models.DateTimeField(blank=True, null=True)
    logout = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'User'

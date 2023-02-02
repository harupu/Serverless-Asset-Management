# Serverless-Asset-Management
This enables you to manage your anti-virus (Windows Defender, ClamAV), Windows Update on PCs and Macs of your organization.

# How to setup

## How to setup slack

Make slack channel for malware alert detection and make the webhook url.

## How to setup SpreadSheet

1. Make new SpleadSheet.
2. Rename first sheet name to `summary`.<br>
<img width="240" alt="image" src="https://user-images.githubusercontent.com/7601382/215703161-7efff8f9-186b-4f3f-97c4-e1e2f4d6f864.png">
3. Select Apps Script menu.
4. Copy and paste asset_management.gs to Apps Script.
5. Click `Deploy` button and select `New deployment`.
6. Select `Web App`, `Execute the app as me` and `ALL`.<br>
<img width="320" alt="image" src="https://user-images.githubusercontent.com/7601382/215706234-8e0d3656-d20c-4ada-97a6-04a50e86b62b.png">
7. And you can get url of SpleadSheet Web App. 

# How to install to PCs

**Note: Please check this script is accepptable or not before run**

1. Copy all files to C drive.
2. Run install.bat as Administraor.<br>
<img src="https://user-images.githubusercontent.com/7601382/77862094-447bba00-7254-11ea-9680-39929e1f3a1e.png" width="320">
3. Click `More Info` and `Run anyway` <br>
<img src="https://user-images.githubusercontent.com/7601382/77862121-64ab7900-7254-11ea-8a97-7be342edfd91.png" width="320">
4. Click `Yes` on UAC dialog <br>
<img src="https://user-images.githubusercontent.com/7601382/77862147-94f31780-7254-11ea-8938-944cf8ff31cd.png" width="320">
5. Type `R` when the security warning is displayed, input your webhook url and input your SpleadSheet url<br>
<img src="https://user-images.githubusercontent.com/7601382/77862237-0e8b0580-7255-11ea-9572-fb5d3e6deaad.png" width="320">
6. Download eicar.com from https://www.eicar.org/ and confirm alert on slack. Alert will be sent within 60s.<br>
<img src="https://user-images.githubusercontent.com/7601382/77862289-73466000-7255-11ea-9413-964e1cccc8b1.png" width="320">
7. And you can collect asset information like below<br>
<img width="500" alt="image" src="https://user-images.githubusercontent.com/7601382/215935150-84613d1b-872e-4df5-a307-22e7d4143811.png">

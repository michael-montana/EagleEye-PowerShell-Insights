![EagleEye-PowerShell-Insights](images/EagleEye-PowerShell-Insights.png)
# 🦅 EagleEye-PowerShell-Insights - Monitor your PowerShell script like a pro!

Ever feel like your PowerShell script is running wild? 🤔 **EagleEye-PowerShell-Insights** is here to keep an eye on everything in real-time, showing you what’s really going on under the hood – all thanks to the power of **Azure Application Insights**!

To my knowlege there is no framework available for PowerShell

## 🔍 What does it do?

With **EagleEye-PowerShell-Insights**, you can monitor your PowerShell scripts with eagle-like precision (of course 🦅). It visualizes logs and data flows in a neural network-like style, so you not only see what's happening but actually get it!

## 🤔 Why did I create this?

As far as I know, there's no framework that integrates PowerShell projects with **Azure Application Insights** – at least not natively. Even Microsoft's own documentation (like [this article](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)) lists many supported languages such as ASP.NET Core, .NET, Java, Node.js, and Python... but **not** PowerShell. That’s where **EagleEye-PowerShell-Insights** steps in – to fill this gap and give PowerShell developers the monitoring tools they deserve!

## 🛠️ Real-world example – why you might need this

Imagine you have to loop through hundreds of Microsoft Tenants and Azure Subscriptions, processing each one with parallel jobs in **Azure Durable Functions**. The real challenge? Finding out where exactly an exception occurred in countless log streams across different Tenant Sessions. With **EagleEye-PowerShell-Insights**, you can easily track logs, associating them with the correct **tenant ID** and pinpointing the precise error message for debugging.

## 🚀 How to get started?

Before you take off, make sure you have PowerShell 7 (the latest and greatest), and then you're ready to roll:

1. **Clone the repo:**
   ```bash
   git clone https://github.com/yourusername/EagleEye-PowerShell-Insights.git

# 📂 Examples? We've got you covered!

## 1️⃣ Simple Example:

   ```powershell
   .\ExampleUsage_Simple_MainRun.ps1
   ```

## 2️⃣ Complex Example:

   ```powershell
   .\ExampleUsage_Complex_MainRun.ps1
   ```

## 3️⃣ Another Complex Example:

   ```powershell
   .\ExampleUsage_Recursive_MainRun.ps1
   ```

# 🌐 Visual Representation

EagleEye-PowerShell-Insights gives you the full monitoring experience with a visual map that looks like a neural network. Each node represents a part of your script. It’s not just cool, it’s practical too!

## 📸 Screenshots (because pictures speak louder than words)



## ⚙️ Prerequisites
1. A Microsoft Azure account with an Application Insights instance.
2. PowerShell 7+ (grab it here)

## 📜 License

EagleEye-PowerShell-Insights is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
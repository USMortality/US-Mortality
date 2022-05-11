const puppeteer = require('puppeteer');
const dateCheckerLog = require('./dateCheckerLog.json')
const { exec } = require("child_process");

async function getDate(page: any, url: string) {
    await page.goto(url);
    return await page.$eval('div.metadata-row:nth-child(2) > dl:nth-child(1) > dd:nth-child(2)', (element: any) => element.textContent)
}

async function hasNewData(): Promise<boolean> {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();

    const date1 = await getDate(page, 'https://data.cdc.gov/NCHS/Weekly-Counts-of-Deaths-by-Jurisdiction-and-Age/y5bj-9g5w')
    console.log(date1)

    const date2 = await getDate(page, 'https://data.cdc.gov/NCHS/Weekly-Provisional-Counts-of-Deaths-by-State-and-S/muzy-jte6/')
    console.log(date2)

    await browser.close();

    if (date1 !== date2) return false
    if (date1 === dateCheckerLog.date) return false
    return true
}

async function main() {
    const shouldUpdate = await hasNewData()

    if (shouldUpdate) {
        let hasError: boolean = false
        exec("./download.sh", (error: any, stdout: string, stderr: string) => {
            if (error) { hasError = true; console.log(`error: ${error.message}`) }
            if (stderr) { hasError = true; console.log(`stderr: ${stderr}`) }
            else console.log(`stdout: ${stdout}`)
        })
        if (hasError) return
        exec("./update.sh", (error: any, stdout: string, stderr: string) => {
            if (error) console.log(`error: ${error.message}`)
            if (stderr) console.log(`stderr: ${stderr}`)
            else console.log(`stdout: ${stdout}`)
        })
    }
}

main()
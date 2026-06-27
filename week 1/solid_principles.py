from abc import ABC, abstractmethod

class Report:
    def __init__(self, title: str, content: str):
        self.title = title
        self.content = content

    def get_formatted_report(self) -> str:
        return f"Title: {self.title}\nContent: {self.content}"

class ReportSaver(ABC):
    @abstractmethod
    def save(self, report: Report):
        pass

class FileReportSaver(ReportSaver):
    def __init__(self, filename: str):
        self.filename = filename

    def save(self, report: Report):
        with open(self.filename, 'w') as file:
            file.write(report.get_formatted_report())
        print(f"Report saved successfully to {self.filename}")

if __name__ == "__main__":
    my_report = Report("Week 1 Progress", "Completed all foundational Python exercises.")
    file_saver = FileReportSaver("progress_report.txt")
    file_saver.save(my_report)
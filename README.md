<a name="readme-top"></a>

# 📗 Table of Contents

- [📗 Table of Contents](#-table-of-contents)
- [Participatory Budgeting System](#participatory-budgeting-system)
  - [🛠 Built With](#-built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
  - [🚀 Live Demo](#-live-demo)
  - [🚀 Video](#-video)
  - [💻 Getting Started](#-getting-started)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [Installation](#installation)
    - [Option 2: Docker](#option-2-docker)
    - [Usage](#usage)
    - [Run tests and Fix linter errors](#run-tests-and-fix-linter-error)
  - [👥 Authors](#-authors)
  - [🔭 Future Features](#-future-features)
  - [🤝 Contributing](#-contributing)
  - [⭐️ Show your support](#️-show-your-support)
  - [🙏 Acknowledgments](#-acknowledgments)
  - [📝 License](#-license)

<!-- PROJECT DESCRIPTION -->

# Participatory Budgeting System <a name="participatory-budgeting-system"></a>

**Participatory Budgeting System** is a web application designed to manage and facilitate participatory budgeting processes for organizations. It allows administrators to set budget cycles, define category spending limits, manage multi-phase voting, and assess project impacts. Voters can browse projects, filter by impact metrics, and cast votes within defined rules.

## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

> Developed using Ruby on Rails.

<details>
  <summary>Languages and Frameworks</summary>
  <ul>
    <li><a href="https://rubyonrails.org/">Ruby on Rails</a></li>
    <li><a href="https://www.ruby-lang.org/">Ruby</a></li>
    <li><a href="https://www.postgresql.org/">PostgreSQL</a></li>
  </ul>
</details>

### Key Features <a name="key-features"></a>

- **Category-Based Spending Limits**: Enforces spending limits for budget categories (e.g., 40% for infrastructure) with real-time validation and admin monitoring.
- **Multi-Phase Voting Workflow**: Supports multiple voting phases (pre-selection, final voting, implementation) with phase-specific rules and automatic transitions.
- **Impact Assessment Integration**: Allows project creators to submit impact metrics (e.g., estimated beneficiaries, sustainability score) and voters to filter projects based on these metrics.
- **Admin Dashboard**: Provides interfaces for setting category limits, monitoring utilization rates, and managing voting phases.
- **Soft Deletion**: Uses `acts_as_paranoid` for soft deletion of records, ensuring data recovery and auditability.

## 🚀 Demo <a name="live-Video"></a>

- [Demo](https://youtu.be/9P_lQPzJHDY)

## 💻 Getting Started <a name="getting-started"></a>

> To get a local copy up and running, follow these steps.

### Prerequisites

In order to run this project you need:

- Ruby 3.2.2 or higher
- Rails 7.0 or higher
- PostgreSQL 13 or higher
- A code editor (e.g., VS Code)
- Git installed

### Setup

Clone this repository to your desired folder:

```bash
git clone https://github.com/Haywayaheadshot/seng_uw_th_ror.git
cd seng_uw_th_ror
```

### Installation

Install this project with:

```bash
bundle install
rails db:setup
```

### Usage

To run the project, execute the following command:

```bash
./bin/dev
```

Then, open `http://localhost:3000` in your browser.

### Run tests and Fix linter errors

To run tests, execute:

```bash
bundle exec rspec
```

To test a specific file:

```bash
bundle exec rspec spec/models/budget_cycle_spec.rb
```

To fix linter errors:

```bash
bundle exec rubocop -A
```

## 👥 Authors <a name="authors"></a>

👤 **Your Name**

- GitHub: [@Haywayaheadshot](https://github.com/Haywayaheadshot)
- LinkedIn: [Abuabakar Ummar](https://www.linkedin.com/in/abubakar-ummar/)

## 🔭 Future Features <a name="future-features"></a>

- [ ] **User Authentication**: Add user roles (e.g., admin, voter) with authentication to secure access.
- [ ] **Real-Time Reporting**: Implement live dashboards for phase-specific analytics and impact reports.
- [ ] **Notification System**: Notify users of phase transitions or voting deadlines.
- [ ] **API Integration**: Expose endpoints for external systems to interact with the budgeting process.

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](https://github.com/Haywayaheadshot/seng_uw_th_ror.git/issues).

## ⭐️ Show your support <a name="support"></a>

Give a ⭐️ if you like this project!

## 🙏 Acknowledgments <a name="acknowledgments"></a>

I would like to thank the open-source community for tools like Ruby on Rails and RSpec.

## 📝 License <a name="license"></a>

This project is [MIT](./LICENSE) licensed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
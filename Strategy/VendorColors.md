# Strategy for Vendor Colors & Recipe Generation

This document outlines the strategy for understanding and eventually replicating the color recipe generation process from the external application.

## 1. The Core Problem

The primary goal is to translate a digital RGB color value into a physical paint mixing recipe using a specific set of `VendorColors` (e.g., Schmincke Norma Professional Oils). This process is currently handled by an external "black box" application. Our objective is to reverse-engineer this logic so it can be integrated directly into the `Vettore` app.

## 2. Data-Driven Approach

Since we don't have access to the external app's source code, we will use a data-driven approach. By collecting and analyzing a sufficient number of sample inputs (RGB colors) and outputs (paint recipes), we can infer the underlying patterns and rules of the conversion process.

## 3. Identifying Core Mixing Colors

A key insight is that not all available vendor colors are used as base ingredients in recipes. There is likely a smaller, core set of "mixing colors" that are used to create all other shades. Our initial data gathering should focus on identifying this core set.

## 4. Enriching the Database Model

To support this data-gathering effort, we will enhance the existing `VendorColors` table in our Drift database. The current table only stores basic information. We will add new columns to capture the physical properties of the paints, which are crucial for accurate color mixing simulation.

### Proposed Schema Changes for `VendorColors` Table:

-   **`isMixingColor` (BOOLEAN):** A flag to explicitly mark a color as a primary mixing ingredient. This will be `false` by default.
-   **`transparency` (TEXT):** To store the paint's transparency rating (e.g., "O" for Opaque, "ST" for Semi-Transparent, "T" for Transparent).
-   **`permanence` (TEXT):** To store the paint's lightfastness or permanence rating (e.g., "A", "AA").
-   **`colorIndexName` (TEXT):** To store the universal pigment identifier(s) for the color (e.g., "PR122", "PV19, PR206"). This is the most scientifically accurate way to identify a color.

## 5. Data Collection Process

The next step is to systematically gather data from the external app and other resources (like the websites we've found). For various target RGB colors, we will record the generated recipes and update our `VendorColors` database with the new metadata (`isMixingColor`, `transparency`, etc.).

This structured dataset will be the foundation for the future development of an in-app `ColorRecipeService`.
